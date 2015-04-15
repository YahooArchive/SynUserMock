/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import "SNBMailSaver.h"
#import "SynUserMock.h"
#import "SNBBugCreateModelProtocol.h"
#import "SynUserMock_private.h"
#import <MessageUI/MessageUI.h>

@interface SNBMailSaver() <MFMailComposeViewControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, copy) SNBBugSaverCompletionBlock completionBlock;

@end


@implementation SNBMailSaver

- (BOOL)saveBugWithModel:(id<SNBBugCreateModel>)model withPresentingViewController:(UIViewController *)viewController completionBlock:(SNBBugSaverCompletionBlock)completionBlock
{
    self.completionBlock = completionBlock;
    
    if([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        
        NSArray *recipients = [self recipients];
        if (recipients && recipients.count > 0) {
            [mailViewController setToRecipients:recipients];
        }
        [mailViewController setSubject:@"Bug report"];
        
        NSString *summary = [model summary];
        if(summary) {
            [mailViewController setMessageBody:summary isHTML:NO];
        }
        
        NSData *pdfData = [model pdfReport];
        if(pdfData) {
           [mailViewController addAttachmentData:pdfData mimeType:@"application/pdf" fileName:@"bugReport.pdf"];
        }
        
        NSData *crashData = [model crashReport];
        if(crashData) {
            [mailViewController addAttachmentData:crashData mimeType:@"text/plain" fileName:@"crash.txt"];
        }
        
        NSData *consoleData = [model consoleLog];
        if(consoleData) {
            [mailViewController addAttachmentData:consoleData mimeType:@"text/plain" fileName:@"console.log"];
        }
        
        NSData *networkData = [model networkLog];
        if(networkData) {
            [mailViewController addAttachmentData:networkData mimeType:@"text/xml" fileName:@"network.xml"];
        }
        
        [viewController presentViewController:mailViewController animated:YES completion:NULL];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mail not configured"
                                                        message:@"You must configure your an email account in the phone settings"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles: nil];
        [alert show];
 }
    
    return YES;
}

- (NSArray *)recipients
{
    NSMutableArray *recipients = [[NSMutableArray alloc] init];
    
    NSDictionary *defaults = [self rootDefaults];
    if(defaults) {
        NSArray *additionalRecipients = defaults[@"recipients"];
        if(additionalRecipients) {
            [recipients addObjectsFromArray:additionalRecipients];
        }
    }
    
    return recipients;
}

- (NSDictionary *)rootDefaults {
    NSDictionary *properties = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:kSNBConfigFile ofType:@"plist"];
    if(filePath) {
        properties = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    }
    
    NSDictionary *defaults = properties[@"Mail"];
    return defaults;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.completionBlock) {
            self.completionBlock(NO);
        }
    });
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [controller dismissViewControllerAnimated:YES completion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if(self.completionBlock) {
                self.completionBlock(result == MFMailComposeResultSent && !error);
            }
        });
    }];
}

- (BOOL)isAvailable
{
    return [MFMailComposeViewController canSendMail];
}

- (NSString *)unavailableMessage
{
    NSString *unavailableMessage = nil;
    if(![MFMailComposeViewController canSendMail]) {
        unavailableMessage = @"You must configure your an email account in the phone settings.";
    } else {
        unavailableMessage = @"Unable to send mail.";
    }
    
    return unavailableMessage;
}


@end
