/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import <Foundation/Foundation.h>
#import "SNBBugCreateModelProtocol.h"

@protocol SNBBugSaver;
@protocol SynUserMockDelegate;

@interface SNBBugCreateModel : NSObject <SNBBugCreateModel>

- (instancetype)initWithSaver:(id<SNBBugSaver>)saver withContentPath:(NSString *)contentPath customFields:(NSDictionary *)customFields delegate:(id<SynUserMockDelegate>)delegate completionBlock:(SNBBugCreateModelCompletionBlock)modelCompletionBlock;

@end
