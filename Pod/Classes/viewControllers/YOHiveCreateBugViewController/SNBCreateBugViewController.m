/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import "SNBCreateBugViewController.h"
#import "SNBBugCreateModel.h"
#import "SNBAnnotateViewController.h"
#import "SNBScreenShotCollectionCell.h"

#import "SNBBugCreateCellDelegate.h"
#import "SNBBugCreateModelCell.h"
#import "SNBBugCreateSummaryCell.h"

@interface SNBCreateBugViewController () <SNBBugCreateCellDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, copy) SNBCreateBugViewControllerDismissBlock dismissBlock;
@property (nonatomic, strong) id<SNBBugCreateModel>model;
@property (nonatomic, strong) IBOutlet UITextField *summary;
@property (nonatomic, assign) BOOL didShowBouncerLogin;

@end

@implementation SNBCreateBugViewController

- (instancetype)initWithModel:(id<SNBBugCreateModel>)model dismissBlock:(SNBCreateBugViewControllerDismissBlock)dismissBlock
{
    self = [super init];
    if(self) {
        self.model = model;
        self.dismissBlock = dismissBlock;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.model reloadData];
    [self.tableView reloadData];
}

- (void)setupView
{
    self.title = @"New Bug";
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    UIBarButtonItem *createButton = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStylePlain target:self action:@selector(createButtonPressed)];
    createButton.accessibilityLabel = @"Create";
    self.navigationItem.rightBarButtonItem = createButton;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed)];
    cancelButton.accessibilityLabel = @"Cancel";
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    NSSet *cellTypes = [self.model cellTypes];
    for(Class<SNBBugCreateModelCell>cellType in cellTypes) {
        [self.tableView registerNib:[UINib nibWithNibName:[cellType identifier] bundle:nil] forCellReuseIdentifier:[cellType identifier]];
    }
}

- (void)createButtonPressed
{
    if(![self.model isValidFeedback]) {
        [self showErrorWithTitle:nil message:[self.model invalidFeedbackMessage]];
    } else {
        __weak SNBCreateBugViewController *weakSelf = self;
        [self.model saveWithPresentingViewController:self completionBlock:^(id<SNBBugCreateModel>modeCreator) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [weakSelf dismissViewControllerAnimated:YES completion:NULL];
                if(weakSelf.dismissBlock) {
                    weakSelf.dismissBlock(weakSelf);
                }
            }];
        }];
    }
}

- (void)showErrorWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles: NSLocalizedString(@"Ok", nil), nil];
    [alert show];
}

- (void)cancelButtonPressed
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{        
        [self dismissViewControllerAnimated:YES completion:NULL];
        if(self.dismissBlock) {
            self.dismissBlock(self);
        }
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.model numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.model numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<SNBBugCreateModelCell> modelCell = [self.model cellModelForRowAtIndexPath:indexPath];
    
    UITableViewCell <SNBBugCreateCell> *cell = [tableView dequeueReusableCellWithIdentifier:[[modelCell class] identifier]];
    cell.model = modelCell;
    cell.delegate = self;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
    return CGRectGetHeight(cell.bounds);
}

#pragma SNBBugCreateCellDelegate

- (void)didSelectScreenShotWithDataItem:(SNBStateDataItem *)item
{
    // only supported on iOS 7+
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        SNBAnnotateViewController *controller = [[SNBAnnotateViewController alloc] initWithDataItem:item];
        controller.modalPresentationStyle = UIModalPresentationFullScreen;
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [self.navigationController pushViewController:controller animated:YES];
        } else {
            [self presentViewController:controller animated:YES completion:^{
                
            }];
        }
    }
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGFloat keyBoardHeight = 0;
    
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        keyBoardHeight = keyboardSize.height;
    } else {
        keyBoardHeight = keyboardSize.width;
    }
    
    CGRect frame = [UIApplication sharedApplication].keyWindow.frame;
    frame.size.height -= keyBoardHeight;
    
    NSNumber *rate = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    [UIView animateWithDuration:rate.floatValue animations:^{
        self.tableView.frame = frame;
    }];
    
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    CGRect frame = self.view.bounds;
    self.tableView.frame = frame;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
