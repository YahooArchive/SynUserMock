/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import "HFDraggableView.h"
#import <QuartzCore/QuartzCore.h>

@interface HFDraggableView ()

@property (nonatomic, assign) BOOL moved;
@property (nonatomic, assign) BOOL scaledDown;
@property (nonatomic, assign) CGPoint startTouchPoint;

@end

@implementation HFDraggableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


#pragma mark - Override Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    _startTouchPoint = [touch locationInView:self];
    
    _scaledDown = YES;
    
    if([_delegate respondsToSelector:@selector(draggableViewHold:)]) {
        [_delegate draggableViewHold:self];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint movedPoint = [touch locationInView:self];
    
    CGFloat deltaX = movedPoint.x - _startTouchPoint.x;
    CGFloat deltaY = movedPoint.y - _startTouchPoint.y;
    [self _moveByDeltaX:deltaX deltaY:deltaY];
    _scaledDown = NO;
    _moved = YES;
    
    if([_delegate respondsToSelector:@selector(draggableView:didMoveToPoint:)]) {
        [_delegate draggableView:self didMoveToPoint:movedPoint];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self endUpTouch];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self endUpTouch];
}

- (void)endUpTouch
{
    if (!_moved) {
        if([_delegate respondsToSelector:@selector(draggableViewTouched:)]) {
          [_delegate draggableViewTouched:self];
        }
    } else {
        if([_delegate respondsToSelector:@selector(draggableViewReleased:)]) {
            [_delegate draggableViewReleased:self];
        }
    }
    
    _moved = NO;
}

#pragma mark - Animations
#define CGPointIntegral(point) CGPointMake((int)point.x, (int)point.y)

- (void)_moveByDeltaX:(CGFloat)x deltaY:(CGFloat)y
{
    [UIView animateWithDuration:0.3f animations:^{
        CGPoint center = self.center;
        center.x += x;
        center.y += y;
        self.center = CGPointIntegral(center);
    }];
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
}

@end
