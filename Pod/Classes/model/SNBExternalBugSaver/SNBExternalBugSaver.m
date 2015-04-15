/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import "SNBExternalBugSaver.h"
#import "SNBBugCreateModelProtocol.h"

@interface SNBExternalBugSaver()

@property (nonatomic, strong) id<SNBBugCreateModel>model;

@end

@implementation SNBExternalBugSaver

- (instancetype)initWithModel:(id<SNBBugCreateModel>)model
{
    self = [super init];
    if(self) {
        self.model = model;
    }
    
    return self;
}

- (NSString *)summary {
    return [self.model summary];
}

- (NSData *)pdfReport {
    return [self.model pdfReport];
}

- (NSData *)crashReport {
    return [self.model crashReport];
}

- (NSData *)consoleLog {
    return [self.model consoleLog];
}

- (NSData *)networkLog {
    return [self.model networkLog];
}

- (NSDictionary *)customFields {
    return [self.model customFields];
}

- (NSDictionary *)additionalFiles {
    return [self.model additionalFiles];
}

@end
