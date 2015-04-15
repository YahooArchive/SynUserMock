/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import "HVUIControl+SNB.h"
#import "SynUserMock.h"
#import "UIView+SNB.h"
#import "SNBStateDataItem.h"
#import "SynUserMock_private.h"
#import <JRSwizzle/JRSwizzle.h>

@implementation UIControl (SNB)

+ (void)installIntercept
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error = nil;
        [[self class] jr_swizzleMethod:@selector(sendAction:to:forEvent:) withMethod:@selector(intercept_SendAction:to:forEvent:) error:&error];
    });
}

#pragma mark - Method Swizzling

- (void)intercept_SendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
{
    // ignore if the control doesn't respond to the selector
    if([target respondsToSelector:action]) {        
        [self intercept_SendAction:action to:target forEvent:event];
        
        if(![self isKindOfClass:[UITextField class]] && ![self isKindOfClass:[UITextView class]]) {
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
            [dictionary setObject:[self viewControllerName] forKey:kSNBKeyClass];
            
            if(self.accessibilityLabel) {
                [dictionary setObject:self.accessibilityLabel forKey:kSNBKeyDescription];
            }
            
            UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
            UITouch *touch = [[event allTouches] anyObject];
            CGPoint touchPoint = [touch locationInView:keyWindow];
            
            SNBStateDataItem *data = [[SNBStateDataItem alloc] initWithDictionary:dictionary withTouchPoint:touchPoint];
            [[SynUserMock sharedInstance] saveStateWithData:data];
        }
    }
}

@end
