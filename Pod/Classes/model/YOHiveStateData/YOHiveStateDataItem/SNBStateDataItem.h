/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import <Foundation/Foundation.h>

static NSString *kSNBCreateDateClass = @"kSNBCreateDateClass";
static NSString *kSNBKeyClass = @"kSNBKeyClass";

@interface SNBStateDataItem : NSObject <NSCopying>

@property (nonatomic, assign, readonly) CGPoint touchPoint;
@property (nonatomic, strong, readonly) NSDate *createDate;

- (NSDictionary *)data;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary withTouchPoint:(CGPoint)touchPoint;
- (void)writeToFile:(NSString *)file path:(NSString *)path;
- (instancetype)initWithFile:(NSString *)file path:(NSString *)path;
- (void)updateValue:(id)value forKey:(NSString *)key;
- (NSString *)viewControllerName;
- (UIImage *)screenShot;

@end
