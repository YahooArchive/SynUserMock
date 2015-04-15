/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

static NSString *kScreenShot_Template = @"kScreenShot_Template";

@interface SNBTemplateModel()

- (void)drawImage:(UIImage *)image inFrame:(CGRect)frame;
- (void)drawText:(NSString *)text withAttributes:(NSDictionary *)attributes inFrame:(CGRect)frame;
- (void)handleView:(UIView *)view forLabel:(NSString *)label withUserInfo:(NSDictionary *)userInfo;

@end