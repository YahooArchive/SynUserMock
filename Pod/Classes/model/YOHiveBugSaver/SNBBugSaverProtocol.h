/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import <Foundation/Foundation.h>

static const NSString *kSNBPDFPath = @"kSNBPDFPath";
static const NSString *kSNBCrashPath = @"kSNBCrashPath";

@protocol SNBAuthenticateModel;
@protocol SNBBugCreateModel;

@protocol SNBBugSaver <NSObject>

/**
 *  SNBBugSaverCompletionBlock
 *
 *  @param success          Whether the save report operation finished successfully or not.
 *
 */
typedef void (^SNBBugSaverCompletionBlock)(BOOL success);

@property (nonatomic, readonly, getter = isAvailable) BOOL available;

- (BOOL)saveBugWithModel:(id<SNBBugCreateModel>)model withPresentingViewController:(UIViewController *)viewController completionBlock:(SNBBugSaverCompletionBlock)completionBlock;
- (NSString *)unavailableMessage;

@end
