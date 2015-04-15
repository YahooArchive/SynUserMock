/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import <Foundation/Foundation.h>

typedef void (^SNBSaveStateCompletionBlock)();

@class SNBStateDataItem;

@interface SNBStateSaver : NSObject

@property (nonatomic, strong, readonly) NSString *contentPath;

- (void)saveWithRequest:(NSURLRequest *)request response:(NSURLResponse *)response data:(NSData *)data userInfo:(NSDictionary *)userInfo;
- (void)saveWithData:(NSData *)data item:(SNBStateDataItem *)item completion:(SNBSaveStateCompletionBlock)completion;
- (void)saveWithException:(NSException *)exception;
- (void)purgePath:(NSString *)purgePath excludePaths:(NSSet *)excludeSubPaths;
- (void)addOperation:(NSOperation *)operation;

@end
