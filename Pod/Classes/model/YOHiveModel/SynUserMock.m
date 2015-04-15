/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import "SynUserMock.h"
#import "SNBStateDataProtocol.h"
#import "SNBStateDataStoryBoard.h"
#import "SNBStateSaver.h"
#import "SNBStateDataItem.h"
#import "SNBBugCreateModelProtocol.h"
#import "SNBMailSaver.h"
#import "SNBBugCreateModel.h"
#import "SNBCreateBugViewController.h"
#import "HVUIWindow+SNB.h"
#import "SNBStateSaverXMLSessionWriter.h"
#import "SNBExternalSaver.h"
#import "SynUserMock_private.h"
#import "HVUITableViewCell+SNB.h"
#import "HVUIControl+SNB.h"
#import "NSURLConnection+SNB.h"
#import "HVUIWindow+SNB.h"
#import "HFDraggableView+BugImage.h"

static SynUserMock *sharedInstance = nil;
static NSString *kSNBSaverKeyFeedback = @"feedback";
static NSString *kSNBSaverKeyMail = @"mail";
static NSString *kSNBSaverKeyExternal = @"external";
static NSString *kSNBSaverKeyMailAndFeedback = @"mailAndfeedback";
static NSString *kSNBSaver = @"SNBSaver";
static NSString *kConfigStealhMode = @"stealthMode";

@interface SynUserMock() <UIAlertViewDelegate, HFDraggableViewDelegate>

@property (nonatomic, strong) id<SNBStateData>stateData;
@property (nonatomic, strong) SNBStateSaver *stateSaver;
@property (nonatomic, strong) id<SNBAuthenticateModel> authModel;
@property (nonatomic, strong) Reachability *reachability;
@property (nonatomic, assign) CFAbsoluteTime lastMemoryWarning;
@property (nonatomic, weak) SNBCreateBugViewController *bugViewController;
@property (nonatomic, strong) HFDraggableView *bugView;
@property (atomic, strong) NSMutableDictionary *customFields;

@end

@implementation SynUserMock

+ (void)initialize {
    if (self == [SynUserMock class]) {
        sharedInstance = [[SynUserMock alloc] init];
        [sharedInstance installIntercepts];
        
        NSLog(@"SynUserMock Activated");
    }
}

+ (SynUserMock *)sharedInstance
{
    return sharedInstance;
}

- (instancetype) init
{
    self = [super init];
    if(self) {
        self.stateSaver = [[SNBStateSaver alloc] init];
        self.stateData = [[SNBStateDataStoryBoard alloc] init];
        self.reachability = [Reachability reachabilityWithHostname:@"www.yahoo.com"];
        self.customFields = [[NSMutableDictionary alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyWindowChanged) name:UIWindowDidBecomeKeyNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    
    return self;
}

- (void)installIntercepts
{
    [UITableViewCell installIntercept];
    [UIControl installIntercept];
    [NSURLConnection installIntercept];
    [UIWindow installIntercept];
    
    NSString *configBugWindowActivator = [self configDictionary][kBugWindowActivator];
    if([configBugWindowActivator isEqualToString:kBugWindowActivatorIcon]) {
        
        self.bugView = [HFDraggableView draggableViewWithImage:[UIImage imageNamed:@"icn_bug"]];
        self.bugView.alpha = 0.75f;
        self.bugView.delegate = self;
        [self keyWindowChanged];
    }
}

- (void)draggableViewTouched:(HFDraggableView *)view
{
    [self presentBugViewController];
}


- (void)keyWindowChanged
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [keyWindow addSubview:self.bugView];
}

- (void)didReceiveMemoryWarning
{
    self.lastMemoryWarning = CFAbsoluteTimeGetCurrent();
}

- (void)saveStateWithData:(SNBStateDataItem *)item
{
    if(!self.bugViewController)
    {
        // don't take a screen shot if we've gotten a memory warning in the last 1 second.
        // slower devices (iPad 2) can't keep up with fast user interaction and taking screen shots
        // doesn't help the situation.
        if(CFAbsoluteTimeGetCurrent() - self.lastMemoryWarning > 1)
        {
            if(![NSThread isMainThread]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSData *data = [self.stateData stateWithItem:item afterScreenUpdate:NO];
                    if(data) {
                        [self.stateSaver saveWithData:data item:item completion:NULL];
                    }
                });
            } else {
                NSData *data = [self.stateData stateWithItem:item afterScreenUpdate:NO];
                if(data) {
                    [self.stateSaver saveWithData:data item:item completion:NULL];
                }
            }
        }
    }
}

- (void)saveStateWithData:(SNBStateDataItem *)item afterScreenUpdate:(BOOL)afterScreenUpdate completion:(SNBSaveStateCompletionBlock)completion
{
    NSData *data = [self.stateData stateWithItem:item afterScreenUpdate:afterScreenUpdate];
    if(data) {
        [self.stateSaver saveWithData:data item:item completion:completion];
    }
}

- (id<SNBAuthenticateModel>)authModel
{
    return _authModel;
}

- (id<SNBBugSaver>)bugSaver
{
    NSString *configSaver = [self configDictionary][kSNBSaver];
    id<SNBBugSaver> saver = nil;
    if(configSaver && [configSaver isEqualToString:kSNBSaverKeyExternal]) {
        saver = [[SNBExternalSaver alloc] init];
    } else {
        saver = [[SNBMailSaver alloc] init];
    }
    
    return saver;
}

- (NetworkStatus)networkStatus
{
    return [self.reachability currentReachabilityStatus];
}

- (void)presentBugViewController
{
    if(!self.bugViewController) {
        
        SNBStateDataItem *dataItem = [[SNBStateDataItem alloc] initWithDictionary:nil withTouchPoint:CGPointZero];
        NSData *data = [self.stateData stateWithItem:dataItem afterScreenUpdate:NO];
                
        SNBSaveStateCompletionBlock completionBlock = NULL;
        BOOL configStealthMode = [[self configDictionary][kConfigStealhMode] boolValue];
        
        if(!configStealthMode) {
            
            UIViewController *presentViewController = [self rootViewController];
            id<SNBBugCreateModel> creator = [[SNBBugCreateModel alloc] initWithSaver:[self bugSaver] withContentPath:self.stateSaver.contentPath
                                                                        customFields:self.customFields delegate:self.delegate completionBlock:^(id<SNBBugCreateModel>modeCreator) {
                                                                            [self resetStateSaver];
                                                                        }];
            
            SNBCreateBugViewController *viewController = [[SNBCreateBugViewController alloc] initWithModel:creator dismissBlock:^(UIViewController *viewController) {
                self.bugView.hidden = NO;
            }];
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
            navController.modalPresentationStyle = UIModalPresentationFormSheet;
            self.bugView.hidden = YES;
            self.bugViewController = viewController;
            
            completionBlock = ^{
                [presentViewController presentViewController:navController animated:YES completion:NULL];
            };
        } else {
            completionBlock = ^{
                // only available in external saver
                id<SNBBugSaver> saver = [[SNBExternalSaver alloc] init];
                id<SNBBugCreateModel> model = [[SNBBugCreateModel alloc] initWithSaver:saver withContentPath:self.stateSaver.contentPath
                                                                            customFields:self.customFields delegate:self.delegate completionBlock:^(id<SNBBugCreateModel>modeCreator) {
                                                                                [self resetStateSaver];
                                                                            }];
                [model updateSummary:@"Stealth Mode"];
                [model saveWithPresentingViewController:nil completionBlock:NULL];
            };
        }
        
        if(data) {
            [self.stateSaver saveWithData:data item:dataItem completion:completionBlock];
        } else if(completionBlock) {
            completionBlock();
        }
    }
}

- (void)saveXMLTransactionWithRequest:(NSURLRequest *)request response:(NSURLResponse *)response data:(NSData *)data userInfo:(NSDictionary *)userInfo
{
    [self.stateSaver saveWithRequest:request response:response data:data userInfo:userInfo];
}


#pragma mark - Crash Handling

- (void)logUncaughtException:(NSException *)exception
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@(1) forKey:kUncaughtExceptionKey];
    [defaults setObject:self.stateSaver.contentPath forKey:kUncaughtExceptionPathKey];
    [defaults synchronize];
    
    [self.stateSaver saveWithException:exception];
    [self saveStateWithData:nil];
}

- (void)appDidFinishLaunching
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSNumber *launchState = [defaults objectForKey:kUncaughtExceptionKey];
        if([launchState boolValue]) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"A crash was detected.\nWould you like to create a bug for this crash?"
                                                           delegate:self
                                                  cancelButtonTitle:@"No"
                                                  otherButtonTitles:@"Yes", nil];
            [alert show];
        }
        [defaults removeObjectForKey:kUncaughtExceptionKey];
        [defaults synchronize];
    }];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1) {
        [alertView dismissWithClickedButtonIndex:buttonIndex animated:NO];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *path = [defaults objectForKey:kUncaughtExceptionPathKey];
        [defaults removeObjectForKey:kUncaughtExceptionPathKey];
        
        id<SNBBugSaver> saver = [self bugSaver];
        id<SNBBugCreateModel> creator = [[SNBBugCreateModel alloc] initWithSaver:saver
                                                                 withContentPath:path
                                                                customFields:self.customFields delegate:self.delegate completionBlock:^(id<SNBBugCreateModel>modeCreator) {
                                                                    [self resetStateSaver];
                                                                }];
        
        SNBCreateBugViewController *viewController = [[SNBCreateBugViewController alloc] initWithModel:creator dismissBlock:^(UIViewController *viewController) {
            self.bugView.hidden = NO;
        }];
        self.bugView.hidden = YES;
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
        UIViewController *presentingViewController = [self rootViewController];
        [presentingViewController presentViewController:navController animated:YES completion:NULL];
    }
}

- (UIViewController *)rootViewController
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    UIViewController *presentViewController = [keyWindow topRootViewController];
    
    return presentViewController;
}

- (void) resetStateSaver
{
    self.stateSaver = [[SNBStateSaver alloc] init];
    self.bugViewController = nil;
}

- (void)addOperation:(NSOperation *)operation
{
    if(operation) {
        [self.stateSaver addOperation:operation];
    }
}

- (void)addCustomFieldValue:(id)value forKey:(id)key
{
    @synchronized(self) {
        NSAssert(value, @"Value is nil");
        NSAssert(key, @"Key is nil");
        
        if(value && key) {
            [self.customFields setObject:value forKey:key];
        } else {
            NSLog(@"%s - Unable to add custom field.  Value and/or key is nil.", __PRETTY_FUNCTION__);
        }
    }
}

- (void)clearCustomFields
{
    @synchronized(self) {
        [self.customFields removeAllObjects];
    }
}

- (void)clearCustomFieldForKey:(id)key
{
    @synchronized(self) {
        NSAssert(key, @"Key is nil");
        
        if(key) {
            [self.customFields removeObjectForKey:key];
        }
    }
}

- (NSDictionary *)configDictionary
{
    NSDictionary *properties = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:kSNBConfigFile ofType:@"plist"];
    if(filePath) {
        properties = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    }
    
    return properties;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
