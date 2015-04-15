/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import "HVUITableViewCell+SNB.h"
#import "SynUserMock.h"
#import "UIView+SNB.h"
#import "SNBStateDataItem.h"
#import "SynUserMock_private.h"
#import <JRSwizzle/JRSwizzle.h>

@implementation UITableViewCell (SNB)

+ (void)installIntercept
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error = nil;
        [[self class] jr_swizzleMethod:@selector(touchesEnded:withEvent:) withMethod:@selector(intercept_touchesEnded:withEvent:) error:&error];
    });
}

- (void)intercept_touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self intercept_touchesEnded:touches withEvent:event];
    
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

@end
