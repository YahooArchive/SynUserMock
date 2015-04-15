/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import "SNBStateSaveOperation.h"
#import "SNBStateDataItem.h"
#import "SynUserMock.h"
#import "SynUserMock_private.h"

@interface SNBStateSaveOperation()

@property (nonatomic, assign) BOOL isExecuting;
@property (nonatomic, assign) BOOL isFinished;

@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) SNBStateDataItem *item;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, assign) BOOL success;
@property (nonatomic, strong) NSString *filename;

@end

@implementation SNBStateSaveOperation

- (instancetype)initWithData:(NSData *)data withPath:(NSString *)path item:(SNBStateDataItem *)item
{
    self = [super init];
    if(self) {
        self.data = data;
        self.item = item;
        self.path = path;
    }
    return self;
}

- (void)start
{
    [self setExecuting];
    
    self.filename  = [NSString stringWithFormat:@"%f", [self.item.createDate timeIntervalSince1970]];
    
    NSString *screenShotPath = [self.path stringByAppendingPathComponent:kScreenShotPathComponent];
    NSString *dataFile = [NSString stringWithFormat:@"%@.jpg", self.filename];
    self.success = [self.data writeToFile:[screenShotPath stringByAppendingPathComponent:dataFile] atomically:YES];
    
    [self.item writeToFile:self.filename path:self.path];
    
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
