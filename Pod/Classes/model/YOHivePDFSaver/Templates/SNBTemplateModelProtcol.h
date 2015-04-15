/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import <Foundation/Foundation.h>

static NSString *kScreenShotFilePath_Template = @"kScreenShotFilePath_Template";
static NSString *kPageCount_Template = @"kPageCount_Template";
static NSString *kAppName_Template = @"kAppName_Template";
static NSString *kImageBundle_Template = @"kImageBundle_Template";
static NSString *kView_Template = @"kView_Template";
static NSString *kAppVersion_Template = @"kAppVersion_Template";
static NSString *kCreator_Template = @"kCreator_Template";
static NSString *kCreateDate_Template = @"kCreateDate_Template";
static NSString *kBuildNumber_Template = @"kBuildNumber_Template";
static NSString *kCustomFields_Template = @"kCustomFields_Template";
static NSString *kCustomFieldsHeader_Template = @"kCustomFieldsHeader_Template";
static NSString *kLabelTitle_Template = @"kLabelTitle_Template";
static NSString *kConnectionType_Template = @"kConnectionType_Template";
static NSString *kOSVersion_Template = @"kOSVersion_Template";
static NSString *kDeviceType_Template = @"kDeviceType_Template";
static NSString *kDeviceModel_Template = @"kDeviceModel_Template";

static NSString *kHeader_Template = @"kHeader_Template";
static NSString *kInfo_Template = @"kInfo_Template";

static NSString *kDataItem = @"kDataItem";

@protocol SNBTemplateModel <NSObject>

- (void)drawWithUserInfo:(NSDictionary *)userInfo;

@end
