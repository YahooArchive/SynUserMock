/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import "SNBTemplateModel.h"
#import "SNBTemplateModel_Private.h"
#import <CoreText/CoreText.h>

@interface SNBTemplateModel()

@end

@implementation SNBTemplateModel

- (UIView *)rootView
{
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil];
    return [objects firstObject];
}

- (void)drawWithUserInfo:(NSDictionary *)userInfo
{
    UIGraphicsBeginPDFPageWithInfo(self.rootView.frame, nil);
    
    UIView *rootView = [self rootView];
    NSArray *subViews = [rootView subviews];
    __block UILabel *customFieldHeader = nil;
    __block UILabel *customFieldValue = nil;
    
    [subViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger index, BOOL *stop) {
        
        if([view accessibilityLabel]) {
            
            // Skip custom fields here... We'll draw them later
            if([view.accessibilityLabel isEqualToString:kCustomFieldsHeader_Template]) {
                customFieldHeader = (UILabel *) view;
            } else if([view.accessibilityLabel isEqualToString:kCustomFields_Template]) {
                customFieldValue = (UILabel *) view;
            } else {
                [self handleView:view forLabel:[view accessibilityLabel] withUserInfo:userInfo];
            }
        }
    }];
    
    // draw custom fields
    if(userInfo[kCustomFields_Template] && customFieldHeader && customFieldValue) {
        [self handleCustomFields:userInfo[kCustomFields_Template] withHeader:customFieldHeader withValue:customFieldValue];
    }
}

- (void)handleView:(UIView *)view forLabel:(NSString *)label withUserInfo:(NSDictionary *)userInfo
{
    if([view isKindOfClass:[UILabel class]]) {
        UILabel *labelView = (UILabel *)view;
        NSString *text = [label isEqualToString:kLabelTitle_Template] ? labelView.text : userInfo[label];
        [self drawLabel:labelView withText:text];
    } else if([label isEqualToString:kScreenShot_Template]) {
        NSString *screenShotPath = userInfo[kScreenShotFilePath_Template];
        UIImage *anImage = [[UIImage alloc] initWithContentsOfFile:screenShotPath];
        [self drawImage:anImage inFrame:view.frame];
    } else if([label isEqualToString:kImageBundle_Template]) {
        UIImageView *imageView = (UIImageView *)view;
        [self drawImage:imageView.image inFrame:view.frame];
    } else if([label isEqualToString:kView_Template]) {
        [self drawView:view inFrame:view.frame];
    }
}

- (void)handleCustomFields:(NSDictionary *)customFields withHeader:(UILabel *)headerLabel withValue:(UILabel *)valueLabel
{
    NSDictionary *headerAttributes = [self attributesForLabel:headerLabel];
    NSDictionary *valueAttributes = [self attributesForLabel:valueLabel];
    __block CGRect headerFrame = headerLabel.frame;
    __block CGRect valueFrame = valueLabel.frame;
    
    [customFields enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        
        NSString *formattedKey = [NSString stringWithFormat:@"%@:", key];
        [self drawText:formattedKey withAttributes:headerAttributes inFrame:headerFrame];
        [self drawText:value withAttributes:valueAttributes inFrame:valueFrame];
        
        headerFrame.origin.y += CGRectGetHeight(headerFrame);
        valueFrame.origin.y = CGRectGetMinY(headerFrame);
    }];
}

- (NSDictionary *)attributesForLabel:(UILabel *)labelView
{
    NSMutableParagraphStyle *headerParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    headerParagraphStyle.alignment = labelView.textAlignment;
    
    NSDictionary *attributes = @{NSFontAttributeName: labelView.font,
                                 NSForegroundColorAttributeName: labelView.textColor,
                                 NSParagraphStyleAttributeName: headerParagraphStyle,
                                 };
    return attributes;
}

- (void)drawLabel:(UILabel *)labelView withText:(NSString *)text
{
    NSDictionary *attributes = [self attributesForLabel:labelView];
    [self drawText:text withAttributes:attributes inFrame:labelView.frame];
}



#pragma mark - Drawing

- (void)drawImage:(UIImage *)image inFrame:(CGRect)frame
{
    [image drawInRect:frame];
}

- (void)drawText:(NSString *)text withAttributes:(NSDictionary *)attributes inFrame:(CGRect)frame
{
    // Apple returning YES when checking for NSString respond to selector drawInRect:withAttributes:
    // for iOS < 7 even though that method is iOS > 7
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
       [text drawInRect:frame withAttributes:attributes];
    } else if([text respondsToSelector:@selector(drawInRect:withFont:)]) {
        [text drawInRect:frame withFont:attributes[NSFontAttributeName]];
    }
}

- (void)drawView:(UIView *)view inFrame:(CGRect)frame
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    [view.backgroundColor setFill];
    CGContextFillRect(context, frame);    
    CGContextRestoreGState(context);
}

@end
