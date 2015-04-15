/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import "SNBStateSaver.h"
#import "SNBStateDataItem.h"
#import "SNBStateSaveOperation.h"
#import "SNBStateSaverPurgeOperation.h"
#import "SNBStateSaverAddPathOperation.h"
#import "SNBStateSaverExceptionOperation.h"
#import "SNBStateSaverPurgeFilesOperation.h"
#import "SNBStateSaverConsoleOperation.h"
#import "SNBStateSaverXMLTransactionWriter.h"
#import "SNBStateSaverXMLSessionWriter.h"
#import "SynUserMock.h"
#import "SynUserMock_private.h"

static const NSString *defaultsKey = @"SNB";
static NSString *kSNBBaseName = @"snb";
static NSString *kMaxScreenShots = @"maxScreenShots";
static NSString *kMaxNetworkLogs = @"maxNetworkLogs";

@interface SNBStateSaver()

@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) NSOperationQueue *networkOperationQueue;
@property (nonatomic, strong) NSString *contentPath;
@property (nonatomic, strong) NSString *baseDirectory;
@property (nonatomic, strong) NSString *basePathName;
@property (nonatomic, strong) NSString *screenShotPath;

@end

@implementation SNBStateSaver

- (instancetype) init
{
    self = [super init];
    if(self) {
        
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.operationQueue.maxConcurrentOperationCount = 1;
        
        [self createRootPath];
        
        NSSet *excludePaths = nil;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSNumber *launchState = [defaults objectForKey:kUncaughtExceptionKey];
        if([launchState boolValue]) {
            id uncaughtObjectKeyValue = [defaults objectForKey:kUncaughtExceptionPathKey];
            if (uncaughtObjectKeyValue) {
                excludePaths = [NSSet setWithObject:[defaults objectForKey:kUncaughtExceptionPathKey]];
            }            
        }
        
        [self purgePath:[self rootPath] excludePaths:excludePaths];
        [self addPath:[[NSUUID UUID] UUIDString]];
    }
    
    return self;
}

- (void)saveWithData:(NSData *)data item:(SNBStateDataItem *)item completion:(SNBSaveStateCompletionBlock)completion;
{
    SNBStateSaveOperation *operation = [[SNBStateSaveOperation alloc] initWithData:data withPath:self.contentPath item:item];
    [self.operationQueue addOperation:operation];
    
    __weak SNBStateSaveOperation *weakOp = operation;
    [operation setCompletionBlock:^{
        SNBStateSaveOperation *strongOp = weakOp;
        BOOL success = strongOp.success;
        if(success) {            
            NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.screenShotPath error:NULL];
            if(files.count > [self maxScreenShots]) {
                SNBStateSaverPurgeFilesOperation *purgeOp = [[SNBStateSaverPurgeFilesOperation alloc]
                                                                initWithPurgePaths:@[[self.contentPath stringByAppendingPathComponent:kScreenShotPathComponent],
                                                                                     [self.contentPath stringByAppendingPathComponent:kItemsPathComponent]]
                                                                fileCount:1];
                [self.operationQueue addOperation:purgeOp];
            }
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if(completion) {
                completion();
            }
        }];
    }];
}

- (void)saveWithRequest:(NSURLRequest *)request response:(NSURLResponse *)response data:(NSData *)data userInfo:(NSDictionary *)userInfo
{
    SNBStateSaverXMLTransactionWriter *operation = [[SNBStateSaverXMLTransactionWriter alloc] initWithRequest:request response:response data:data userInfo:userInfo contentPath:self.contentPath];
    [self.operationQueue addOperation:operation];

    __weak SNBStateSaverXMLTransactionWriter *weakOp = operation;
    [operation setCompletionBlock:^{
        SNBStateSaverXMLTransactionWriter *strongOp = weakOp;
        BOOL success = strongOp.success;
        if(success) {
            NSString *path = [self.contentPath stringByAppendingPathComponent:kNetworkPathComponent];
            NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
            if(files.count > [self maxNetworkLogs]) {
                SNBStateSaverPurgeFilesOperation *purgeOp = [[SNBStateSaverPurgeFilesOperation alloc] initWithPurgePaths:@[path] fileCount:1];
                [self.operationQueue addOperation:purgeOp];
            }
        }
    }];
}

- (void)saveWithException:(NSException *)exception
{
    SNBStateSaverExceptionOperation *operation = [[SNBStateSaverExceptionOperation alloc] initWithPath:self.contentPath exception:exception];
    [operation setQueuePriority:NSOperationQueuePriorityHigh];
    [self.operationQueue addOperation:operation];
}

- (void)purgePath:(NSString *)purgePath excludePaths:(NSSet *)excludeSubPaths
{
    SNBStateSaverPurgeOperation *operation = [[SNBStateSaverPurgeOperation alloc] initWithPurgePath:purgePath excludeSubPaths:excludeSubPaths];
    [self.operationQueue addOperation:operation];
}

- (void)addPath:(NSString *)pathName
{
    SNBStateSaverAddPathOperation *operation = [[SNBStateSaverAddPathOperation alloc] initWithPathName:pathName rootPath:[self rootPath]];
    [self.operationQueue addOperation:operation];
    
    __weak SNBStateSaverAddPathOperation *weakOp = operation;
    [operation setCompletionBlock:^{
        SNBStateSaverAddPathOperation *strongOp = weakOp;
        BOOL success = strongOp.success;
        if(success) {
            self.contentPath = strongOp.contentPath;
            self.basePathName = strongOp.basePathName;
            self.screenShotPath = [self.contentPath stringByAppendingPathComponent:kScreenShotPathComponent];
        }
    }];
}

- (void)createRootPath
{
    [self.operationQueue addOperationWithBlock:^{
        NSString *path = [[self documentDirectory] stringByAppendingPathComponent:kSNBBaseName];
        if(![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            NSError *error = nil;
            [[NSFileManager defaultManager] createDirectoryAtPath:[[self documentDirectory] stringByAppendingPathComponent:kSNBBaseName] withIntermediateDirectories:NO attributes:nil error:&error];
        }
    }];
}

- (NSString *)rootPath
{
    return [[self documentDirectory] stringByAppendingPathComponent:kSNBBaseName];
}

- (NSString *)documentDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
}

- (NSUInteger)maxScreenShots
{
    NSNumber *configMaxScreenShots = [[SynUserMock sharedInstance] configDictionary][kMaxScreenShots];
    return [configMaxScreenShots integerValue] ? [configMaxScreenShots integerValue] : 15;
}

- (NSUInteger)maxNetworkLogs
{
    NSNumber *configMaxNetworkLogs = [[SynUserMock sharedInstance] configDictionary][kMaxNetworkLogs];
    return [configMaxNetworkLogs integerValue] ? [configMaxNetworkLogs integerValue] : 15;
}

- (void)addOperation:(NSOperation *)operation
{
    [self.operationQueue addOperation:operation];
}

@end
