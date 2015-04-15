/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import <Foundation/Foundation.h>
#import "SNBBugCreateModelCell.h"

@protocol SNBBugCreateSummaryModel <SNBBugCreateModelCell>

- (void)updateSummaryWithText:(NSString *)text;
- (NSString *)summary;

@end

@interface SNBBugCreateSummaryModel : NSObject <SNBBugCreateSummaryModel>

@end
