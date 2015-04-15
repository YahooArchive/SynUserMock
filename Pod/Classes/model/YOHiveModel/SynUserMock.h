/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import <Foundation/Foundation.h>
#import "SNBModelProtocol.h"

@protocol SynUserMockDelegate <NSObject>

@optional

/**
 *  An optional call which is called immediately before a feedback report will be sent.
 */
- (void)synUserMockWillSendFeedback;


/**
 *  An optional call which is called just after a report is sent.
 *
 *  @param success      Returns if the report was sent successfully.
 */
- (void)synUserMockDidSendFeedback:(BOOL)success;


/**
 *  An optional call which can return additional files to send with the feedback report.
 *
 *  @return NSDictionary        Each entry in the dictionary should contain: The key should be the filename of type NSString and 
 *                              the value should be the files contents of type NSData.
 */
- (NSDictionary *)synUserMockAdditionalFilesForFeedback;


/**
 *  An optional call which can return additional fields added to the feedback report.  These fields are displayed on the first page of the report and are
 *  added as tags if the report is sent to the Feedback Server.
 *
 *  @return NSDictionary        Each entry in the dictionary should contain: The key should be the field title of type NSString and
 *                              the value should be of type NSString.
 */
- (NSDictionary *)synUserMockCustomFieldsForFeedback;


/**
 *  An optional call which will determine if this network request will be logged.
 *
 *  @param NSURLRequest      The NSURLRequest which is about to be logged.
 *
 *  @return BOOL             Return YES if you want to log this network request, otherwise return NO.
 */
- (BOOL)synUserMockWillLogNetworkRequest:(NSURLRequest *)request;


/**
 *  An optional call which will transfer the responsiblity of saving the report to you.  By implementing this call you are responsible for saving this report.
 *  This method is called when the user taps the send button on SynUserMock bug create menu.
 *
 *  @param id<SNBExternalBugSaver>)     Contains the data (pdfReport, console log, additional files, custom fields, etc).
 *  @param UIViewController             The modal viewController which is displaying the SynUserMock create report screen.  This viewController will
 *                                      be dismissed when the synUserMockSaveReport:withPresentingViewController:completionBlock: delegate method
 *                                      calls the completionBlock.
 *  @param SNBBugSaverCompletionBlock   A non NULL completion block which must be called after you have finished saving the bug report.
 *
 */
- (void)synUserMockSaveReport:(id<SNBExternalBugSaver>)model withPresentingViewController:(UIViewController *)viewController completionBlock:(SNBBugSaverCompletionBlock)completionBlock;


/**
 *  An optional call which will tell SynUserMock to blur the current screen shot being captured.
 *
 *  @param Class             Current top level viewController classs.
 *
 *  @return BOOL             Return YES if you want to to blur the screen shot from this class, otherwise return NO.
 */
- (BOOL)synUserMockShouldBlurScreenShotOfViewControllerForClass:(Class)viewController;


/**
 *  An optional call which will set the blur radius for the current screen shot being blurred.
 *
 *  @param Class             Current top level viewController classs.
 *
 *  @return CGFloat          Return the blur radius for the current screen shot.  synUserMockShouldBlurImage: must return YES, otherwise this value is
                             ignored. Defaults to 5.
 */
- (CGFloat)synUserMockBlurRadiusForClass:(Class)viewController;

@end


@interface SynUserMock : NSObject

+ (SynUserMock *)sharedInstance;

/**
 *  Presents that bug compose window (this is the same window that would appear when you shake the device).
 */
- (void)presentBugViewController;


/**
 *  This is the only call required for SynUserMock to start.  This should be called in your appDidFinishLaunching method.
 */
- (void)appDidFinishLaunching;


/**
 *  An optional call that can be added to your uncaughtExceptionHandler method just before a crash occurs.  
 *  Calling this method will result an alert window popping up the next time the app launches.  The popup will ask the user if he would like
 *  to create and send the crash data.
 *
 *  @param exception    The exception which was raised in your uncaughtExceptionHandler
 */
- (void)logUncaughtException:(NSException *)exception;


/**
 *  Adds a custom field (key/value) to your feedback report.
 *
 *  @warning    This method has been deprecated.  Instead set the SynUserMock delegate and implement the synUserMockCustomFieldsForFeedback method.
 */
- (void)addCustomFieldValue:(id)value forKey:(id)key __attribute((deprecated("Set the SynUserMock delegate and implement the synUserMockCustomFieldsForFeedback method.")));


/**
 *  Clears a custom field.
 *
 *  @warning    This method has been deprecated.
 */
- (void)clearCustomFieldForKey:(id)key __attribute((deprecated("This method is no longer needed. Set the SynUserMock delegate and implement the synUserMockCustomFieldsForFeedback method.")));


/**
 *  Clears a custom field.
 *
 *  @warning    This method has been deprecated.
 */
- (void)clearCustomFields __attribute((deprecated("This method is no longer needed. Set the SynUserMock delegate and implement the synUserMockCustomFieldsForFeedback method.")));


@property (nonatomic, weak) id<SynUserMockDelegate> delegate;

@end
