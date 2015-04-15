/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import "UIView+SNB.h"

@implementation UIView (SNB)

- (NSString *) viewControllerName
{
    NSString *className = nil;
    for (UIView *next = [self superview]; next; next = next.superview)
    {
        UIResponder* nextResponder = [next nextResponder];
        
        if ([nextResponder isKindOfClass:[UIViewController class]])
        {
            className = NSStringFromClass([nextResponder class]);
            break;
        }
    }
    
    if(!className) {
        className = @"";
    }
    
    return className;
}

@end
