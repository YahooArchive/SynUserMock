/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import "SNBExternalSaver.h"
#import "SynUserMock.h"
#import "SNBBugCreateModelProtocol.h"
#import "SNBExternalBugSaver.h"
#import "SynUserMock_private.h"

@implementation SNBExternalSaver


- (BOOL)saveBugWithModel:(id<SNBBugCreateModel>)model withPresentingViewController:(UIViewController *)viewController completionBlock:(SNBBugSaverCompletionBlock)completionBlock
{
    if([[SynUserMock sharedInstance].delegate respondsToSelector:@selector(synUserMockSaveReport:withPresentingViewController:completionBlock:)]) {
        id<SNBExternalBugSaver> externalSaver = [[SNBExternalBugSaver alloc] initWithModel:model];
        [[SynUserMock sharedInstance].delegate synUserMockSaveReport:externalSaver withPresentingViewController:viewController completionBlock:completionBlock];
    } else {
        NSAssert(0, @"SynUserMock - Is configured for an External Saver via SNB.plit but it's delegate does not implement synUserMockSaveReport:withPresentingViewController:completionBlock:");
    }
    
    return YES;
}

- (BOOL)isAvailable
{
    return [[SynUserMock sharedInstance].delegate respondsToSelector:@selector(synUserMockSaveReport:withPresentingViewController:completionBlock:)];
}

- (NSString *)unavailableMessage
{
    return @"Bug report sending is unavailable";
}

@end
