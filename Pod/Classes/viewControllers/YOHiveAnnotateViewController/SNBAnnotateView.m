/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import "SNBAnnotateView.h"
#import "SNBDraggableView.h"
#import "SNBStroke.h"

@interface SNBAnnotateView()

@property (nonatomic, strong) NSMutableArray* allPaths;
@property (nonatomic, strong) NSMutableArray* undoPaths;
@property (nonatomic, strong) UIBezierPath* currentPath;

@property (nonatomic, strong) SNBDraggableView* draggableView;

@end

@implementation SNBAnnotateView

#pragma mark - Initializer

- (id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    
    return self;
}

- (void)awakeFromNib {
    [self setupView];
}

- (void)dealloc {
    [self.allPaths removeAllObjects];
    [self.undoPaths removeAllObjects];
}

- (void) setupView {
    
    self.backgroundColor = [UIColor clearColor];
    self.allPaths = [NSMutableArray array];
    self.undoPaths = [NSMutableArray array];
    self.multipleTouchEnabled = NO;
}

#pragma mark - UIView hooks

- (void) touchesBegan:(NSSet *) touches withEvent:(UIEvent *) event
{
    if ([event touchesForView:self]) {
        // Initialize a new path for the user gesture
        self.currentPath = [UIBezierPath bezierPath];
        self.currentPath.lineWidth = 4.0f;
        
        UITouch *touch = [touches anyObject];
        [self.currentPath moveToPoint:[touch locationInView:self]];
    }
}

- (void) touchesMoved:(NSSet *) touches withEvent:(UIEvent *) event
{
    if ([event touchesForView:self]) {
        // Add new points to the path
        UITouch *touch = [touches anyObject];
        [self.currentPath addLineToPoint:[touch locationInView:self]];
        [self setNeedsDisplay];
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([event touchesForView:self]) {
        UITouch *touch = [touches anyObject];
        [self.currentPath addLineToPoint:[touch locationInView:self]];
        
        SNBStroke* pathStroke = [SNBStroke new];
        pathStroke.strokeColor = self.strokeColor;
        pathStroke.path = self.currentPath;
        
        [self.allPaths addObject:pathStroke];
        [self.undoPaths removeAllObjects];
        self.currentPath = nil;
        [self setNeedsDisplay];
    }
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

- (void) drawRect:(CGRect)rect
{
    
    if (self.strokeColor) {
        [self.strokeColor setStroke];
    } else {
        [[UIColor blackColor] setStroke];
    }
    
    [self.currentPath stroke];
    // Draw the path
    for (SNBStroke* strokePath in self.allPaths) {
        [strokePath.strokeColor setStroke];
        [strokePath.path strokeWithBlendMode:kCGBlendModeNormal alpha:1.0];
    }
    
    if (self.strokeColor) {
        [self.strokeColor setStroke];
    }
}

#pragma mark - public methods

- (BOOL)undo {

    BOOL undoSuccessful = NO;
    
    if ([self.allPaths count] > 0) {
        SNBStroke* strokePathToUndo = [self.allPaths lastObject];
        [self.undoPaths addObject:strokePathToUndo];
        [self.allPaths removeObject:strokePathToUndo];
        [self setNeedsDisplay];
        undoSuccessful = YES;
    }
    
    return undoSuccessful;
}

- (BOOL)moreToUndo {
    return (self.allPaths.count > 0);
}

- (BOOL)undoAll {
    
    BOOL undoSuccessful = NO;
    
    if ([self.allPaths count] > 0) {
        [self.allPaths removeAllObjects];
        [self setNeedsDisplay];
        undoSuccessful = YES;
    }
    
    return undoSuccessful;
}

- (BOOL)redo {
    
    BOOL redoSuccessful = NO;
    
    if ([self.undoPaths count] > 0) {
        SNBStroke* strokePathToRedo = [self.undoPaths lastObject];
        [self.allPaths addObject:strokePathToRedo];
        [self.undoPaths removeObject:strokePathToRedo];
        [self setNeedsDisplay];
        redoSuccessful = YES;
    }
    return redoSuccessful;
}

- (BOOL)moreToRedo {
    return (self.undoPaths.count > 0);
}

@end
