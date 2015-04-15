/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import "SNBStateSaverPurgeFilesOperation.h"
#import "SynUserMock.h"

@interface SNBStateSaverPurgeFilesOperation()

@property (nonatomic, assign) BOOL isExecuting;
@property (nonatomic, assign) BOOL isFinished;

@property (nonatomic, strong) NSArray *paths;
@property (nonatomic, assign) NSUInteger fileCount;

@property (nonatomic, assign) BOOL success;

@end

@implementation SNBStateSaverPurgeFilesOperation

- (instancetype)initWithPurgePaths:(NSArray *)paths fileCount:(NSUInteger)fileCount
{
    self = [super init];
    if(self) {
        self.paths = paths;
        self.fileCount = fileCount;
    }
    return self;
}

- (BOOL)purgeFilesWithPath:(NSString *)path
{
    BOOL success = YES;
    NSArray *files = [self filesForPath:path];
    NSUInteger counter = 0;
    NSError *error = nil;
    
    for(NSString *aFile in files) {

        if(!error) {
            [[NSFileManager defaultManager] removeItemAtPath:[path stringByAppendingPathComponent:aFile] error:&error];
        }
        
        counter++;
        
        if(error) {
            success = NO;
            break;
        }
        
        if(counter >= self.fileCount) {
            break;
        }
    }
    
    return success;
}

- (void)start
{
    [self setExecuting];
    
    BOOL success = NO;
    for(NSString *aPath in self.paths) {
        
        success = [self purgeFilesWithPath:aPath];
        
        if(!success) {
            break;
        }
    }
    self.success = success;
    
	[self setFinished];
}

- (void)setExecuting
{
    [self willChangeValueForKey:@"isExecuting"];
    self.isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

- (NSArray *)filesForPath:(NSString *)path
{
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES selector:@selector(localizedCompare:)];
    NSArray *sortedFiles = [files sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    return sortedFiles;
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
