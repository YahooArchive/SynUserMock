/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import <Foundation/Foundation.h>

@interface SNBStateSaverXMLTransactionWriter : NSOperation

@property (nonatomic, assign, readonly) BOOL success;
- (instancetype)initWithRequest:(NSURLRequest *)request response:(NSURLResponse *)response data:(NSData *)data userInfo:(NSDictionary *)userInfo contentPath:(NSString *)contentPath;

@end
