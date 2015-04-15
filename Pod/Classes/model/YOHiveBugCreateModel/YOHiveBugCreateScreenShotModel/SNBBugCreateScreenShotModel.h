/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import <Foundation/Foundation.h>
#import "SNBBugCreateModelCell.h"

@class SNBStateDataItem;

@protocol SNBBugCreateScreenShotModel <SNBBugCreateModelCell>

- (NSUInteger)screenShotCount;
- (SNBStateDataItem *)itemAtIndex:(NSUInteger)index;
- (void)didSelectIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)selectedIndexPath;
- (void)reloadData;

@end

@interface SNBBugCreateScreenShotModel : NSObject <SNBBugCreateScreenShotModel>

- (instancetype)initWithContentPath:(NSString *)contentPath;

@end
