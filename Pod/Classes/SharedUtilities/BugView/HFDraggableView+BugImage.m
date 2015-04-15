/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import "HFDraggableView+BugImage.h"

#import "HFImageView.h"

@implementation HFDraggableView (BugImageView)

+ (id)draggableViewWithImage:(UIImage *)image
{
    HFDraggableView *view = [[HFDraggableView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    
    HFImageView *avatarView = [[HFImageView alloc] initWithFrame:CGRectInset(view.bounds, 4, 4)];
    avatarView.backgroundColor = [UIColor clearColor];
    [avatarView setImage:image];
    avatarView.center = CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds));
    [view addSubview:avatarView];
    return view;
}

@end
