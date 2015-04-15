/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import <Foundation/Foundation.h>

@interface SNBStateSaverPurgeOperation : NSOperation

- (instancetype)initWithPurgePath:(NSString *)basePath excludeSubPaths:(NSSet *)excludeSubPaths;

@end
