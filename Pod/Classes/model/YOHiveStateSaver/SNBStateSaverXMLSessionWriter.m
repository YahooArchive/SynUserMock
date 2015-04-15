/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import "SNBStateSaverXMLSessionWriter.h"
#import "SNBStateTransactionItem.h"
#import "SynUserMock.h"
#import "SynUserMock_private.h"

@interface SNBStateSaverXMLSessionWriter()

@property (nonatomic, assign) BOOL isExecuting;
@property (nonatomic, assign) BOOL isFinished;

@property (nonatomic, strong) NSString *contentPath;
@property (nonatomic, assign) BOOL success;
@property (nonatomic, strong) NSString *filename;

@end

@implementation SNBStateSaverXMLSessionWriter

- (instancetype)initWithContentPath:(NSString *)contentPath
{
    self = [super init];
    if(self) {
        self.contentPath = contentPath;
    }
    return self;
}

- (void)start
{
    NSString *networkPath = [self.contentPath stringByAppendingPathComponent:kNetworkPathComponent];
    NSString *filePath = [self.contentPath stringByAppendingPathComponent:@"network.xml"];
    
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:networkPath error:NULL];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES selector:@selector(localizedCompare:)];
    NSArray *sortedFiles = [files sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSMutableString *session = [[NSMutableString alloc] init];
    [session appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><!DOCTYPE charles-session SYSTEM \"http://www.charlesproxy.com/dtd/charles-session-1_0.dtd\">"];
    [session appendString:@"<charles-session>"];

    
    [sortedFiles enumerateObjectsUsingBlock:^(NSString *dataFileName, NSUInteger idx, BOOL *stop) {
        
        NSData *data = [NSData dataWithContentsOfFile:[networkPath stringByAppendingPathComponent:dataFileName]];
        NSString *transaction = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [session appendString:transaction];
    }];
    
    [session appendString:@"</charles-session>"];
    self.success = [session writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
}

@end
