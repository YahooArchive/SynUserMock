/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import "HVUIWindow+SNB.h"
#import "SNBCreateBugViewController.h"
#import "SynUserMock.h"
#import "SynUserMock_private.h"
#import <JRSwizzle/JRSwizzle.h>

@implementation UIWindow (SNB)

+ (void)installIntercept
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error = nil;
        NSString *configBugWindowActivator = [self configDictionary][kBugWindowActivator];
        
        if(!configBugWindowActivator || [configBugWindowActivator isEqualToString:kBugWindowActivatorShake]) {
            [[self class] jr_swizzleMethod:@selector(motionEnded:withEvent:) withMethod:@selector(intercept_motionEnded:withEvent:) error:&error];
        } else if([configBugWindowActivator isEqualToString:kBugWindowActivator3FingerTap]) {
            [[self class] jr_swizzleMethod:@selector(sendEvent:) withMethod:@selector(intercept_sendEvent:) error:&error];
        }
    });
}

- (void)intercept_motionEnded:(UIEventSubtype)motion withEvent:(UIEvent*)event {
    
    if (event.subtype == UIEventSubtypeMotionShake) {
        [[SynUserMock sharedInstance] presentBugViewController];
    }
}

- (void)intercept_sendEvent:(UIEvent *)event
{
    [self intercept_sendEvent:event];
    if ([event allTouches].count == 3) {
        [[SynUserMock sharedInstance] presentBugViewController];
    }
}


- (UIViewController *)topRootViewController
{
    UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    UIViewController *presentingViewController = rootViewController;
    while (presentingViewController.presentedViewController) {
        presentingViewController = presentingViewController.presentedViewController;
    }
    return presentingViewController;
}

+ (NSDictionary *)configDictionary
{
    NSDictionary *properties = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:kSNBConfigFile ofType:@"plist"];
    if(filePath) {
        properties = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    }
    
    return properties;
}

@end
