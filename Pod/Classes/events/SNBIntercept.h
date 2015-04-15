/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import <Foundation/Foundation.h>

@protocol SNBIntercept <NSObject>

+ (void) installIntercept;

@end


@interface SNBIntercept : NSObject

+ (void)replaceOriginalMethod:(SEL)originalSelector withMethod:(SEL)swizzledSelector forClass:(Class)class withToken:(dispatch_once_t)token;
+ (void)replaceOriginalClassMethod:(SEL)originalSelector withClassMethod:(SEL)swizzledSelector forClass:(Class)class withToken:(dispatch_once_t)onceToken;

@end