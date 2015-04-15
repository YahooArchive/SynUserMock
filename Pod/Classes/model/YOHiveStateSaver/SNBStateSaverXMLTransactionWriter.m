/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import "SNBStateSaverXMLTransactionWriter.h"
#import "SNBStateTransactionItem.h"
#import "SynUserMock.h"
#import "SynUserMock_private.h"

@interface SNBStateSaverXMLTransactionWriter()

@property (nonatomic, assign) BOOL isExecuting;
@property (nonatomic, assign) BOOL isFinished;

@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSString *contentPath;
@property (nonatomic, assign) BOOL success;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, strong) NSString *filename;

@end

@implementation SNBStateSaverXMLTransactionWriter

- (instancetype)initWithRequest:(NSURLRequest *)request response:(NSURLResponse *)response data:(NSData *)data userInfo:(NSDictionary *)userInfo contentPath:(NSString *)contentPath;
{
    self = [super init];
    if(self) {
        self.data = data;
        self.request = request;
        self.response = response;
        self.userInfo = userInfo;
        self.contentPath = contentPath;
    }
    return self;
}

- (BOOL)isValidContentType:(NSString *)contentType
{
    BOOL validContent = NO;
    if(contentType) {
        if([contentType rangeOfString:@"json"].location != NSNotFound) {
            validContent = YES;
        }
    }
    
    return validContent;
}

- (void)start
{
    [self setExecuting];
    
    SNBStateTransactionItem *item = [[SNBStateTransactionItem alloc] initWithRequest:self.request response:self.response data:self.data userInfo:self.userInfo];
    NSData *data = [item toBytes];
    
    self.filename  = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
    NSString *networkPath = [self.contentPath stringByAppendingPathComponent:kNetworkPathComponent];
    NSString *dataFile = [NSString stringWithFormat:@"%@.net", self.filename];
    self.success = [data writeToFile:[networkPath stringByAppendingPathComponent:dataFile] atomically:YES];
    
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
