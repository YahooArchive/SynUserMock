/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import "SNBPDFSaver.h"
#import "SNBTemplateSysInfo.h"
#import "SNBTemplateScreenShot.h"
#import "SNBCoverPage.h"
#import "SynUserMock.h"
#import "SNBStateDataItem.h"
#import "SNBBugCreateModelProtocol.h"
#import "SynUserMock_private.h"

@interface SNBPDFSaver()

@property (nonatomic, weak) id<SNBBugCreateModel> delegate;

@end

@implementation SNBPDFSaver

- (instancetype)initWithDelegate:(id<SNBBugCreateModel>)delegate
{
    self = [super init];
    if(self) {
        self.delegate = delegate;
    }
    return self;
}

- (NSString *)drawPDFWithPath:(NSString *)path
{
    NSString *fileName = [NSString stringWithFormat:@"%@_%@_%.0f.pdf", [self.delegate appName], [self.delegate buildNumber], [[NSDate date] timeIntervalSince1970]];
    NSString *filePath = [path stringByAppendingPathComponent:fileName];
    
    NSString *screenShotPath = [path stringByAppendingPathComponent:kScreenShotPathComponent];
    NSArray *files = [self filesForPath:screenShotPath];
    
    UIGraphicsBeginPDFContextToFile(filePath, CGRectZero, nil);

    NSUInteger pageCount = 1;
    
    id<SNBTemplateModel> sysInfoTempalte = [[SNBTemplateSysInfo alloc] init];
    [sysInfoTempalte drawWithUserInfo:@{kPageCount_Template : [NSString stringWithFormat:@"%lu", (unsigned long)pageCount],
                                        kCustomFields_Template : [self.delegate customFields],
                                        kConnectionType_Template : [self.delegate networkStatus],
                                        kOSVersion_Template : [self.delegate osVersion],
                                        kDeviceType_Template : [self.delegate deviceType],
                                        kAppName_Template : [self.delegate appName],
                                        kImageBundle_Template : kImageBundle_Template,
                                        kAppVersion_Template : [self.delegate appVersion],
                                        kCreateDate_Template : [self.delegate currentDate],
                                        kBuildNumber_Template : [self.delegate buildNumber],
                                        kDeviceModel_Template : [self.delegate deviceModel]
                                        }];
    pageCount++;

    
    id<SNBTemplateModel> screenShotTemplate = [[SNBTemplateScreenShot alloc] init];
    
    NSUInteger screenShotCount = 0;
    for(NSString *aFile in files) {
        
        SNBStateDataItem *item = [[SNBStateDataItem alloc] initWithFile:[aFile stringByDeletingPathExtension] path:path];
        
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:[item data]];
        userInfo[kScreenShotFilePath_Template] = [screenShotPath stringByAppendingPathComponent:aFile];
        userInfo[kPageCount_Template] = [NSString stringWithFormat:@"%lu", (unsigned long)pageCount];
        userInfo[kCreateDate_Template] = [self.delegate currentDate];
        
        [screenShotTemplate drawWithUserInfo:userInfo];
        
        pageCount++;
        screenShotCount++;
    }

    UIGraphicsEndPDFContext();
    
    return filePath;
}

- (NSArray *)filesForPath:(NSString *)path
{
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:NO selector:@selector(localizedCompare:)];
    NSArray *sortedFiles = [files sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    return sortedFiles;
}

@end
