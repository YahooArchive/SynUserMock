/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import <Foundation/Foundation.h>

@interface SNBStateSaverAddPathOperation : NSOperation

@property (nonatomic, strong, readonly) NSString *contentPath;
@property (nonatomic, strong, readonly) NSString *basePathName;
@property (nonatomic, assign, readonly) BOOL success;

- (instancetype)initWithPathName:(NSString *)basePathName rootPath:(NSString *)rootPath;

@end
