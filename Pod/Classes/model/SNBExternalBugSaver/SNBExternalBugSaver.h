/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import <Foundation/Foundation.h>
#import "SNBExternalBugSaverProtocol.h"
#import "SNBBugCreateModelProtocol.h"

@interface SNBExternalBugSaver : NSObject <SNBExternalBugSaver>

- (instancetype)initWithModel:(id<SNBBugCreateModel>)model;

@end
