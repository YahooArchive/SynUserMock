/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

@protocol SNBExternalBugSaver <NSObject>

/**
 *  The summary text the user typed in the SynUserMock create bug viewController.
 *
 *  @return NSDictionary    A non nil NSString containing the text the user typed in the summary field.
 */
- (NSString *)summary;


/**
 *  The PDF report that was generated.  This report contains the screen captures, device information and the additional custom fields.
 *
 *  @return NSData          Non nil NSData containing the PDF report.
 */
- (NSData *)pdfReport;


/**
 *  The symobilicated crash report if the app calls SynUserMock logUncaughtException: method and the app previously crashed.
 *
 *  @return NSData          The symbolicated crash report or nil if it doesn't exists.
 */
- (NSData *)crashReport;


/**
 *  The console log.
 *
 *  @return NSData          The console log or nil if it doesn't exist.
 */
- (NSData *)consoleLog;


/**
 *  The Charles compatible network session log.  This log can be imported in to Charles Proxy.
 *
 *  @return NSData          The network session log or nil if it doesn't exist.
 */
- (NSData *)networkLog;


/**
 *  Any custom fields added by the delegate method synUserMockCustomFieldsForFeedback.
 *
 *  @return NSDictionary          Key/Value pairs of custom fields.  If there are no custom fields you will be returned an empty dictionary.
 */
- (NSDictionary *)customFields;


/**
 *  Any additional files added by the delegate method synUserMockAdditionalFilesForFeedback.
 *
 *  @return NSDictionary          Key/Value pairs of additional files.  nil will be returned if there are no additional files.
 */
- (NSDictionary *)additionalFiles;

@end
