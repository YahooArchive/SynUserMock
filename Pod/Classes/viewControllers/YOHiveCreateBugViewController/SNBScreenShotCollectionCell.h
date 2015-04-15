/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import <UIKit/UIKit.h>

@class SNBStateDataItem;

@interface SNBScreenShotCollectionCell : UICollectionViewCell

- (void)updateWithData:(SNBStateDataItem *)dataItem;
+ (NSString *)identifier;
+ (CGSize)defaultSizeWithData:(SNBStateDataItem *)dataItem;

@end

