/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import "SNBBugCreateModel.h"
#import "SynUserMock.h"
#import "SNBPDFSaver.h"
#import "SNBStateDataItem.h"

#import "SNBBugCreateSummaryModel.h"
#import "SNBBugCreateScreenShotModel.h"
#import "SNBBugSaverProtocol.h"
#import "SNBBugCreateSummaryCell.h"

#import "SNBStateSaverXMLSessionWriter.h"
#import "SNBStateSaverConsoleOperation.h"
#import "SynUserMock_private.h"

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <sys/utsname.h>

NSString *const GCDAsyncCreateBugQueueName = @"GCDAsyncCreateBug";

static NSUInteger kSNBValidDescriptionLength = 4;

@interface SNBBugCreateModel()

@property (nonatomic, strong) id<SNBBugSaver>saver;
@property (nonatomic, weak) id<SynUserMockDelegate>delegate;
@property (nonatomic, strong) NSString *contentPath;
@property (nonatomic, strong) SNBPDFSaver *pdfSaver;
@property (nonatomic, copy) SNBBugCreateModelCompletionBlock modelCompletionBlock;

@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, strong) NSMutableSet *cellTypes;

@property (nonatomic, strong) NSString *pdfPath;
@property (nonatomic, strong) NSString *crashPath;
@property (nonatomic, strong) NSString *consolePath;
@property (nonatomic, strong) NSString *networkPath;
@property (nonatomic, strong) NSString *loggedInUserName;
@property (nonatomic, strong) NSDictionary *customFields;

@property (nonatomic, strong) id<SNBBugCreateSummaryModel>summaryModel;
@property (nonatomic, strong) id<SNBBugCreateScreenShotModel>screenShotModel;


@end

@implementation SNBBugCreateModel

static NSDateFormatter *dateFormatter = nil;

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSTimeZone *pacificTimeZone = [NSTimeZone timeZoneWithName:@"America/Los_Angeles"];
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"M/d/yyyy h:mma";
        dateFormatter.timeZone = pacificTimeZone;
    });
}

- (void)reloadData
{
    [self.screenShotModel reloadData];
}

- (void)setupTableViewCells
{
    self.cellTypes = [[NSMutableSet alloc] init];
    self.sections = [[NSMutableArray alloc] init];
    
    NSMutableArray *rows = [[NSMutableArray alloc] init];
    
    self.summaryModel = [[SNBBugCreateSummaryModel alloc] init];
    [rows addObject: self.summaryModel];
    
    self.screenShotModel = [[SNBBugCreateScreenShotModel alloc] initWithContentPath:self.contentPath];
    [rows addObject:self.screenShotModel];
    
    [self.sections addObject:rows];
    
    for(id<SNBBugCreateModelCell>cell in rows) {
        [self.cellTypes addObject:[cell class]];
    }
}

- (NSInteger)numberOfSections
{
    return self.sections.count;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
    NSArray *rows = self.sections[section];
    return rows.count;
}

- (NSArray *)rowsForSection:(NSInteger)section
{
    return self.sections[section];
}

- (id<SNBBugCreateModelCell>)cellModelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *rows = [self rowsForSection:indexPath.section];
    return rows[indexPath.row];
}

- (NSSet *)cellTypes
{
    return _cellTypes;
}

- (instancetype)initWithSaver:(id<SNBBugSaver>)saver withContentPath:(NSString *)contentPath customFields:(NSDictionary *)customFields delegate:(id<SynUserMockDelegate>)delegate completionBlock:(SNBBugCreateModelCompletionBlock)modelCompletionBlock
{
    self = [super init];
    if(self) {
        self.modelCompletionBlock = modelCompletionBlock;
        self.saver = saver;
        self.delegate = delegate;
        self.contentPath = contentPath;
        self.pdfSaver = [[SNBPDFSaver alloc] initWithDelegate:self];
        self.customFields = customFields;
        
        [self setupTableViewCells];
    }
    
    return self;
}

- (void)saveWithPresentingViewController:(UIViewController *)viewController completionBlock:(SNBBugCreateModelCompletionBlock)completionBlock;
{
    if([self.delegate respondsToSelector:@selector(synUserMockWillSendFeedback)]) {
        [self.delegate synUserMockWillSendFeedback];
    }
    
    dispatch_queue_t queue = dispatch_queue_create([GCDAsyncCreateBugQueueName UTF8String], DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t group = dispatch_group_create();
    
#if TARGET_IPHONE_SIMULATOR != 1
    dispatch_group_async(group, queue, ^ {
        SNBStateSaverConsoleOperation *consoleOperation = [[SNBStateSaverConsoleOperation alloc] initWithPath:self.contentPath];
        [consoleOperation start];
    });
#endif
    
    dispatch_group_async(group, queue, ^ {
        SNBStateSaverXMLSessionWriter *networkOperation = [[SNBStateSaverXMLSessionWriter alloc] initWithContentPath:self.contentPath];
        [networkOperation start];
    });
    
    dispatch_group_async(group, dispatch_get_main_queue(), ^ {
        self.pdfPath = [self.pdfSaver drawPDFWithPath:self.contentPath];
    });
    
    dispatch_group_notify(group, queue, ^ {
        
        NSString *crashPath = [self.contentPath stringByAppendingPathComponent:@"crash.txt"];
        if([[NSFileManager defaultManager] fileExistsAtPath:crashPath]) {
            self.crashPath = crashPath;
        }
        
        NSString *consolePath = [self.contentPath stringByAppendingPathComponent:@"console.log"];
        if([[NSFileManager defaultManager] fileExistsAtPath:consolePath]) {
            self.consolePath = consolePath;
        }
        
        NSString *networkPath = [self.contentPath stringByAppendingPathComponent:@"network.xml"];
        if([[NSFileManager defaultManager] fileExistsAtPath:networkPath]) {
            self.networkPath = networkPath;
        }
        
        __weak SNBBugCreateModel *weakSelf = self;
        [self.saver saveBugWithModel:self withPresentingViewController:viewController completionBlock:^(BOOL success) {
            
            SNBBugCreateModel *strongSelf = weakSelf;            
            dispatch_async(dispatch_get_main_queue(), ^{
                // completion block set from VC level
                if(completionBlock) {
                    completionBlock(strongSelf);
                }
                
                // set at model level
                if(strongSelf.modelCompletionBlock) {
                    strongSelf.modelCompletionBlock(strongSelf);
                }
                
                if([strongSelf.delegate respondsToSelector:@selector(synUserMockDidSendFeedback:)]) {
                    [strongSelf.delegate synUserMockDidSendFeedback:success];
                }
                
                // Need to handle when sending feedback was unsuccessful
                //if(!success) {
                //}
            });
        }];
    });
}

- (BOOL)isValidFeedback {
    return [self isAvailable] && [self summary].length > kSNBValidDescriptionLength;
}

- (NSString *)invalidFeedbackMessage {
    NSString *message = nil;
    
    if(![self isAvailable]) {
        message = [self.saver unavailableMessage];
    } else if([self summary].length <= kSNBValidDescriptionLength) {
        message = [NSString stringWithFormat: @"Your description must be at least %lu characters.", (unsigned long)kSNBValidDescriptionLength+1];
    }
    
    return message;
}

- (NSString *)summary
{
    return [self.summaryModel summary];
}

- (void)updateSummary:(NSString *)summary
{
    [self.summaryModel updateSummaryWithText:summary];
}

- (NSData *)pdfReport
{
    NSData *fileData = nil;
    if(self.pdfPath) {
        fileData = [NSData dataWithContentsOfFile:self.pdfPath];
    }
    return fileData;
}

- (NSData *)crashReport
{
    NSData *fileData = nil;
    if(self.crashPath) {
        fileData = [NSData dataWithContentsOfFile:self.crashPath];
    }
    return fileData;
}

- (NSData *)consoleLog
{
    NSData *fileData = nil;
    if(self.consolePath) {
        fileData = [NSData dataWithContentsOfFile:self.consolePath];
    }
    return fileData;
}

- (NSData *)networkLog
{
    NSData *fileData = nil;
    if(self.networkPath) {
        fileData = [NSData dataWithContentsOfFile:self.networkPath];
    }
    return fileData;
}

- (NSString *)loggedInUserName
{
    NSString *userName = _loggedInUserName;
    
    if(!userName) {
        userName = @"Not logged in";
    }
    
    return userName;
}

- (NSString *)cellularConnectionType
{
    NSString *connectionType = nil;
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    if([networkInfo respondsToSelector:@selector(currentRadioAccessTechnology)]) {
        connectionType = networkInfo.currentRadioAccessTechnology;
    }
    
    return connectionType;
}

- (NSString *)networkStatus
{
    NetworkStatus status = [[SynUserMock sharedInstance] networkStatus];
    NSString *statusString = @"";
    
    switch (status) {
        case NotReachable:
            statusString = @"Network unreachable";
            break;
            
        case ReachableViaWWAN:
        {
            CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
            CTCarrier *carrier = [netinfo subscriberCellularProvider];
            statusString = [NSString stringWithFormat:@"Cellular (%@)", [carrier carrierName]];
        }
            break;
            
        case ReachableViaWiFi:
            statusString = @"WiFi";
            break;
            
        default: break;
    }
    
    return statusString;
}

- (NSString *)deviceModel
{
#if TARGET_IPHONE_SIMULATOR
    return @"Simulator";
#else
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    return platform;
#endif
}

- (NSString *)buildNumber
{
    NSString *buildNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
    
    if(!buildNumber) {
        buildNumber = @"undefined";
    } else {
        buildNumber = [NSString stringWithFormat:@"build %@", buildNumber];
    }
    
    return buildNumber;
}

- (NSString *)osVersion
{
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
    if(!osVersion) {
        osVersion = @"Undefined";
    }
    
    return osVersion;
}

- (NSString *)deviceType
{
    NSString *deviceType = [[UIDevice currentDevice] model];
    if(!deviceType) {
        deviceType = @"Undefined";
    }
    
    return deviceType;
}

- (NSString *)appName
{
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    if(!appName) {
        appName = @"App name undefined";
    }
    return appName;
}

- (NSString *)productID
{
    NSDictionary *defaults = [self rootDefaults][@"Feedback"];
    NSString *productID = defaults[@"productID"];
    if(!productID) {
        productID = @"0";
    }
    return productID;
}

- (NSString *)appVersion
{
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    if(!appVersion) {
        appVersion = @"App version undefined";
    } else {
        appVersion = [NSString stringWithFormat:@"v%@", appVersion];
    }
    return appVersion;
}

- (NSString *)currentDate
{
    return [dateFormatter stringFromDate:[NSDate date]];
}

- (NSString *)defaultLocale
{
    NSString *language = [[NSLocale preferredLanguages] firstObject];
    return language;
}

- (NSDictionary *)customFields
{
    NSDictionary *customFields = @{};
    
    if(_customFields && _customFields.count) {
        customFields = _customFields;
    } else {
        if([self.delegate respondsToSelector:@selector(synUserMockCustomFieldsForFeedback)]) {
            customFields = [self.delegate synUserMockCustomFieldsForFeedback];
            [customFields enumerateKeysAndObjectsWithOptions:0 usingBlock:^(NSString *title, NSString *value, BOOL *stop) {
                NSAssert([title isKindOfClass:[NSString class]], @"SynUserMock - synUserMockCustomFieldsForFeedback: Dictionary keys must be of type NSString");
                NSAssert([value isKindOfClass:[NSString class]], @"SynUserMock - synUserMockCustomFieldsForFeedback: Dictionary values must be of type NSString");
            }];
        }
    }
    
    if(!customFields) {
        customFields = [NSDictionary dictionary];
    }
    
    return customFields;
}

- (NSDictionary *)additionalFiles
{
    NSDictionary *additionalFiles = nil;
    if([self.delegate respondsToSelector:@selector(synUserMockAdditionalFilesForFeedback)]) {
        additionalFiles = [self.delegate synUserMockAdditionalFilesForFeedback];
        [additionalFiles enumerateKeysAndObjectsWithOptions:0 usingBlock:^(NSString *filename, NSData *data, BOOL *stop) {
            NSAssert([filename isKindOfClass:[NSString class]], @"SynUserMock - synUserMockAdditionalFilesForFeedback: Dictionary keys must be of type NSString");
            NSAssert([data isKindOfClass:[NSData class]], @"SynUserMock - synUserMockAdditionalFilesForFeedback: Dictionary values must be of type NSData");
        }];
    }
    
    return additionalFiles;
}

- (BOOL)isAvailable
{
    return self.saver.isAvailable;
}

- (NSString *)unavailableMessage
{
    return [self.saver unavailableMessage];
}

- (NSDictionary *)rootDefaults {
    NSDictionary *properties = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:kSNBConfigFile ofType:@"plist"];
    if(filePath) {
        properties = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    }
    
    return properties;
}

@end
