/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import "SNBStateSaverExceptionOperation.h"

@interface SNBStateSaverExceptionOperation()

@property (nonatomic, assign) BOOL isExecuting;
@property (nonatomic, assign) BOOL isFinished;

@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSException *exception;

@property (nonatomic, assign) BOOL success;

@end


@implementation SNBStateSaverExceptionOperation

- (instancetype)initWithPath:(NSString *)path exception:(NSException *)exception
{
    self = [super init];
    if(self) {
        self.path = path;
        self.exception = exception;
    }
    return self;
}

- (void)start
{
    [self setExecuting];
    
    NSError *error = nil;
    NSString *reason = [self.exception reason];
    NSString *exceptionName = [self.exception name];
    NSArray *callStackSymbols =[self.exception callStackSymbols];
    
    NSString *formattedString = [NSString stringWithFormat:
                                 @"Reason: %@\nException: %@\n\nCall Stack\n%@", reason, exceptionName, callStackSymbols];
    
    [formattedString writeToFile:[self.path stringByAppendingPathComponent:@"crash.txt"] atomically:YES encoding:NSUTF8StringEncoding error:&error];
    self.success = !error;
    
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
