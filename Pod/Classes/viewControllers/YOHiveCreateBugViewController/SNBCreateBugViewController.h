/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import <UIKit/UIKit.h>

@protocol SNBBugCreateModel;

typedef void (^SNBCreateBugViewControllerDismissBlock)(UIViewController *);

@interface SNBCreateBugViewController : UIViewController

- (instancetype)initWithModel:(id<SNBBugCreateModel>)model dismissBlock:(SNBCreateBugViewControllerDismissBlock)dismissBlock;

@end
