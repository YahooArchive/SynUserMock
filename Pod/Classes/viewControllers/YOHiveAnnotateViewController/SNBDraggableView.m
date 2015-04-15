/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import "SNBDraggableView.h"

@interface SNBDraggableView() <UITextViewDelegate>

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UITextView* textView;

@end

@implementation SNBDraggableView

- (id)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        self.textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:self.textView];
        [self.textView setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.25]];
        [self.textView setDelegate:self];
    }
    
    return self;
}

- (void)handlePan:(UIPanGestureRecognizer*)sender
{
	[self adjustAnchorPointForGestureRecognizer:sender];
    
	CGPoint translation = [sender translationInView:[self superview]];
	[self setCenter:CGPointMake([self center].x + translation.x, [self center].y + translation.y)];
    
	[sender setTranslation:(CGPoint){0, 0} inView:[self superview]];
}

- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIView *piece = self;
        CGPoint locationInView = [gestureRecognizer locationInView:piece];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:piece.superview];
        
        piece.layer.anchorPoint = CGPointMake(locationInView.x / piece.bounds.size.width, locationInView.y / piece.bounds.size.height);
        piece.center = locationInSuperview;
    }
}

- (void)setDraggable:(BOOL)draggable
{
	[self.panGesture setEnabled:draggable];
}

- (void)enableDragging
{
	self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
	[self.panGesture setMaximumNumberOfTouches:1];
	[self.panGesture setMinimumNumberOfTouches:1];
	[self.panGesture setCancelsTouchesInView:NO];
	[self addGestureRecognizer:self.panGesture];
}

#pragma mark - UITextViewDelegate methods

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self.textView setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:1.0]];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self.textView setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.25]];
}

@end
