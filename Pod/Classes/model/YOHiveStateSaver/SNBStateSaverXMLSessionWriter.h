/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import <Foundation/Foundation.h>

@interface SNBStateSaverXMLSessionWriter : NSObject

- (instancetype)initWithContentPath:(NSString *)contentPath;
- (void)start;

@end
