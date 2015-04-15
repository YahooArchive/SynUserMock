/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import "SNBIntercept.h"
#import <objc/runtime.h>

@implementation SNBIntercept

+ (void)replaceOriginalMethod:(SEL)originalSelector withMethod:(SEL)swizzledSelector forClass:(Class)class withToken:(dispatch_once_t)onceToken
{
    dispatch_once(&onceToken, ^{
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
        
    });
}

+ (void)replaceOriginalClassMethod:(SEL)originalSelector withClassMethod:(SEL)swizzledSelector forClass:(Class)class withToken:(dispatch_once_t)onceToken
{
    dispatch_once(&onceToken, ^{
        
        Method originalMethod = class_getClassMethod(class, originalSelector);
        Method swizzledMethod = class_getClassMethod(class, swizzledSelector);
        
        Class classObj = object_getClass(class);
        
        BOOL didAddMethod =
        class_addMethod(classObj,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(classObj,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
        
    });
}

@end
