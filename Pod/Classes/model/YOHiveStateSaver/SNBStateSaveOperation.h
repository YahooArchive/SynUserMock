/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import <Foundation/Foundation.h>

@class SNBStateDataItem;

@interface SNBStateSaveOperation : NSOperation

@property (nonatomic, assign, readonly) BOOL success;
@property (nonatomic, strong, readonly) NSString *filename;

- (instancetype)initWithData:(NSData *)data withPath:(NSString *)path item:(SNBStateDataItem *)item;

@end
