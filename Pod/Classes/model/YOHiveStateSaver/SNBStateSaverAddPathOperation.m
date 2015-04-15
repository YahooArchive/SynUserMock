/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import "SNBStateSaverAddPathOperation.h"
#import "SynUserMock.h"
#import "SynUserMock_private.h"

@interface SNBStateSaverAddPathOperation()

@property (nonatomic, assign) BOOL isExecuting;
@property (nonatomic, assign) BOOL isFinished;

@property (nonatomic, strong) NSString *contentPath;
@property (nonatomic, strong) NSString *basePathName;
@property (nonatomic, strong) NSString *rootPath;

@property (nonatomic, assign) BOOL success;

@end

@implementation SNBStateSaverAddPathOperation

- (instancetype)initWithPathName:(NSString *)basePathName rootPath:(NSString *)rootPath
{
    self = [super init];
    if(self) {
        self.basePathName = basePathName;
        self.rootPath = rootPath;
    }
    return self;
}

- (void)start
{
    [self setExecuting];
    
    self.contentPath = [self createDirectory:self.basePathName atFilePath:self.rootPath];
    
	[self setFinished];
}

- (NSString *)createDirectory:(NSString *)directoryName atFilePath:(NSString *)filePath
{
    NSString *rootPath = [filePath stringByAppendingPathComponent:directoryName];
    NSError *errorRootPath;
    NSError *errorScreenShot;
    NSError *errorData;
    
    // root path
    [[NSFileManager defaultManager] createDirectoryAtPath:rootPath withIntermediateDirectories:NO attributes:nil error:&errorRootPath];
    
    // network
    [[NSFileManager defaultManager] createDirectoryAtPath:[rootPath stringByAppendingPathComponent:kNetworkPathComponent] withIntermediateDirectories:NO attributes:nil error:&errorData];
    
    // screen shots
    [[NSFileManager defaultManager] createDirectoryAtPath:[rootPath stringByAppendingPathComponent:kScreenShotPathComponent] withIntermediateDirectories:NO attributes:nil error:&errorScreenShot];
    
    // data items
    [[NSFileManager defaultManager] createDirectoryAtPath:[rootPath stringByAppendingPathComponent:kItemsPathComponent] withIntermediateDirectories:NO attributes:nil error:&errorData];
    
    if(!errorRootPath && !errorScreenShot && !errorData) {
        self.success = YES;
    }
    
    return rootPath;
}

- (void)setExecuting
{
    [self willChangeValueForKey:@"isExecuting"];
    self.isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
}


- (void)setFinished
{
    [self willChangeValueForKey:@"isExecuting"];
    self.isExecuting = NO;
    [self didChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    self.isFinished = YES;
    [self didChangeValueForKey:@"isFinished"];
}

@end
