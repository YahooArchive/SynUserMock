/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import "SNBTemplateScreenShot.h"
#import "SNBTemplateModel_Private.h"

@interface SNBTemplateScreenShot ()

@end

@implementation SNBTemplateScreenShot

- (NSString *)nibNameWithSize:(CGSize)size
{
    NSString *nibName = nil;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        // portrait
        if(size.height > size.width) {
            nibName = @"SNBTemplateScreenShotiPhonePortrait";
        }
        // landscape
        else {
           nibName = @"SNBTemplateScreenShotiPhoneLandscape";
        }
    }
    // iPad
    else {
        
        // portrait
        if(size.height > size.width) {
            nibName = @"SNBTemplateScreenShotiPadPortrait";
        }
        // landscape
        else {
            nibName = @"SNBTemplateScreenShotiPadLandscape";
        }
    }
    
    return nibName;
}

- (UIView *)rootViewWithSize:(CGSize)size
{
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:[self nibNameWithSize:size] owner:nil options:nil];
    return [objects firstObject];
}


- (void)drawWithUserInfo:(NSDictionary *)userInfo
{
    NSString *screenShotPath = userInfo[kScreenShotFilePath_Template];
    UIImage *anImage = [[UIImage alloc] initWithContentsOfFile:screenShotPath];
    
    UIView *rootView = [self rootViewWithSize:anImage.size];
    UIGraphicsBeginPDFPageWithInfo(rootView.frame, nil);
    NSArray *subViews = [rootView subviews];
    [subViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger index, BOOL *stop) {
        
        if([view accessibilityLabel]) {
            [self handleView:view forLabel:[view accessibilityLabel] withUserInfo:userInfo];
        }
    }];
}

@end
