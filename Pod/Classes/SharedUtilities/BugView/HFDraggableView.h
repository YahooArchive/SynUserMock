/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import <UIKit/UIKit.h>

@protocol HFDraggableViewDelegate;
@interface HFDraggableView : UIView

@property (nonatomic, assign) id<HFDraggableViewDelegate> delegate;

@end

@protocol HFDraggableViewDelegate <NSObject>

@optional
- (void)draggableViewTouched:(HFDraggableView *)view;
- (void)draggableViewHold:(HFDraggableView *)view;
- (void)draggableView:(HFDraggableView *)view didMoveToPoint:(CGPoint)point;
- (void)draggableViewReleased:(HFDraggableView *)view;

@end
