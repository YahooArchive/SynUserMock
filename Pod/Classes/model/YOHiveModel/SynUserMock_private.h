/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#define kSNBKeyDescription @"kSNBKeyDescription"

static NSString *kScreenShotPathComponent = @"screenshots";
static NSString *kItemsPathComponent = @"items";
static NSString *kNetworkPathComponent = @"network";
static NSString *kUncaughtExceptionKey = @"SNBUncaughtExceptionKey";
static NSString *kUncaughtExceptionPathKey = @"SNBUncaughtExceptionPathKey";
static NSString *kSNBConfigFile = @"SNB";

static NSString *kBugWindowActivator = @"bugWindowActivator";
static NSString *kBugWindowActivatorShake = @"SNBWindowActivatorShake";
static NSString *kBugWindowActivatorIcon = @"SNBWindowActivatorIcon";
static NSString *kBugWindowActivator3FingerTap = @"SNBWindowActivator3FingerTap";

@interface SynUserMock()

- (void)saveStateWithData:(SNBStateDataItem *)data;
- (void)saveStateWithData:(SNBStateDataItem *)item afterScreenUpdate:(BOOL)afterScreenUpdate completion:(SNBSaveStateCompletionBlock)completion;
- (void)saveXMLTransactionWithRequest:(NSURLRequest *)request response:(NSURLResponse *)response data:(NSData *)data userInfo:(NSDictionary *)userInfo;
- (void)addOperation:(NSOperation *)operation;
- (NetworkStatus)networkStatus;
- (void)presentBugViewController;
- (NSDictionary *)configDictionary;


@end
