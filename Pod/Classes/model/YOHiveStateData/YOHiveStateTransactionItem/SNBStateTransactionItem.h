/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import <Foundation/Foundation.h>

@interface SNBStateTransactionItem : NSObject

- (instancetype)initWithRequest:(NSURLRequest *)request response:(NSURLResponse *)response data:(NSData *)data userInfo:(NSDictionary *)userInfo;
- (NSString *)toString;
- (NSData *)toBytes;

@end
