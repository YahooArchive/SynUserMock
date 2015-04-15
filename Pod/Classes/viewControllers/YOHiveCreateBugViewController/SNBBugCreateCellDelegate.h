/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import <Foundation/Foundation.h>

@class SNBStateDataItem;

@protocol SNBBugCreateCellDelegate <NSObject>

- (void)didSelectScreenShotWithDataItem:(SNBStateDataItem *)item;

@end
