/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import <Foundation/Foundation.h>

@protocol SNBBugCreateModel;

@interface SNBPDFSaver : NSObject

- (instancetype)initWithDelegate:(id<SNBBugCreateModel>)delegate;
- (NSString *)drawPDFWithPath:(NSString *)path;

@end
