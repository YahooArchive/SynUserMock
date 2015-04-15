/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import <UIKit/UIKit.h>

@protocol SNBBugCreateCellDelegate;
@protocol SNBBugCreateModelCell;

@protocol SNBBugCreateCell <NSObject>

@property (nonatomic, assign) id<SNBBugCreateCellDelegate>delegate;
@property (nonatomic, strong) id<SNBBugCreateModelCell>model;

@end 

@interface SNBBugCreateCell : UITableViewCell <SNBBugCreateCell>


@end
