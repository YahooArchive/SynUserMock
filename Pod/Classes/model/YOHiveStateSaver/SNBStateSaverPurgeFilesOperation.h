/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import <Foundation/Foundation.h>

@interface SNBStateSaverPurgeFilesOperation : NSOperation

- (instancetype)initWithPurgePaths:(NSArray *)paths fileCount:(NSUInteger)fileCount;

@end
