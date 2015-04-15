/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import <UIKit/UIKit.h>

@interface SNBAnnotateView : UIView

// Choose the color of the stroke
@property (nonatomic, strong) UIColor* strokeColor;

// Undo the last action, return YES if successful
- (BOOL)undo;

// Returns YES if there is more to undo
- (BOOL)moreToUndo;

// Undo all the actions, return YES if successful
- (BOOL)undoAll;

// Redo the last action, return YES if successful
- (BOOL)redo;

// Returns YES if there is more to redo
- (BOOL)moreToRedo;

@end
