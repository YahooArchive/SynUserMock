/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import "SNBStateSaverPurgeOperation.h"

@interface SNBStateSaverPurgeOperation()

@property (nonatomic, assign) BOOL isExecuting;
@property (nonatomic, assign) BOOL isFinished;

@property (nonatomic, strong) NSString *basePath;
@property (nonatomic, strong) NSSet *excludeSubPaths;

@property (nonatomic, assign) BOOL success;

@end

@implementation SNBStateSaverPurgeOperation

- (instancetype)initWithPurgePath:(NSString *)basePath excludeSubPaths:(NSSet *)excludeSubPaths
{
    self = [super init];
    if(self) {
        self.excludeSubPaths = excludeSubPaths;
        self.basePath = basePath;
    }
    return self;
}

- (void)start
{
    [self setExecuting];
    
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.basePath error:NULL];
    for(NSString *aFile in files)
    {
        NSString *filePath = [self.basePath stringByAppendingPathComponent:aFile];
        if(![self.excludeSubPaths containsObject:filePath]) {
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        }
    }
    
	[self setFinished];
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
