/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import <Foundation/Foundation.h>

@protocol SNBBugCreateModel;

typedef void (^SNBBugCreateModelCompletionBlock)(id<SNBBugCreateModel>);

@protocol SNBBugCreateModelCell;

@protocol SNBBugCreateModel <NSObject>

- (void)saveWithPresentingViewController:(UIViewController *)viewController completionBlock:(SNBBugCreateModelCompletionBlock)completionBlock;

@property (nonatomic, readonly, getter = isAvailable) BOOL available;

- (void)updateSummary:(NSString *)summary;
- (void)reloadData;
- (NSInteger)numberOfSections;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (id<SNBBugCreateModelCell>)cellModelForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSSet *)cellTypes;
- (NSString *)summary;
- (NSData *)pdfReport;
- (NSData *)crashReport;
- (NSData *)consoleLog;
- (NSData *)networkLog;
- (NSString *)cellularConnectionType;
- (NSString *)networkStatus;
- (NSString *)deviceModel;
- (NSString *)buildNumber;
- (NSString *)productID;
- (NSString *)osVersion;
- (NSString *)deviceType;
- (NSString *)appName;
- (NSString *)appVersion;
- (NSString *)currentDate;
- (NSString *)defaultLocale;
- (NSString *)unavailableMessage;
- (NSDictionary *)customFields;
- (NSDictionary *)additionalFiles;

- (BOOL)isValidFeedback;
- (NSString *)invalidFeedbackMessage;

@end
