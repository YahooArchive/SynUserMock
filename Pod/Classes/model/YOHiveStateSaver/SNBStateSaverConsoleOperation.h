/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import <Foundation/Foundation.h>

@interface SNBStateSaverConsoleOperation : NSObject

- (instancetype)initWithPath:(NSString *)path;
- (void)start;

@end
