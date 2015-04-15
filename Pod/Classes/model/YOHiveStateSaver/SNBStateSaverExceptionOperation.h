/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import <Foundation/Foundation.h>

@interface SNBStateSaverExceptionOperation : NSOperation

@property (nonatomic, assign, readonly) BOOL success;

- (instancetype)initWithPath:(NSString *)path exception:(NSException *)exception;

@end
