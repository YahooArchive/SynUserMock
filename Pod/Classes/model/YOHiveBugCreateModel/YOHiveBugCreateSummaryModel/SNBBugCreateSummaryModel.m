/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import "SNBBugCreateSummaryModel.h"

@interface SNBBugCreateSummaryModel()

@property (nonatomic, strong) NSString *summaryText;

@end

@implementation SNBBugCreateSummaryModel

+ (NSString *)identifier
{
    return @"SNBBugCreateSummaryCell";
}

- (void)updateSummaryWithText:(NSString *)text
{
    self.summaryText = text;
}

- (NSString *)summary
{
    return self.summaryText;
}

@end
