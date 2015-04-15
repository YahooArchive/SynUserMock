/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import "SNBAnnotateViewController.h"
#import "SNBStateDataItem.h"
#import "SynUserMock.h"
#import "SNBAnnotateView.h"
#import "UIImage+SNB.h"
#import "SynUserMock_private.h"

NSString *const GCDAsyncSNBAnnotateQueueName = @"GCDAsyncSNBAnnotate";

//CONSTANTS:

#define kBrightness             1.0
#define kSaturation             1.0

#define kPaletteHeight			30
#define kPaletteSize			5
#define kMinEraseInterval		0.5

// Padding for margins
#define kLeftMargin				10.0
#define kTopMargin				10.0
#define kRightMargin			10.0

//CLASS IMPLEMENTATIONS:

@interface SNBAnnotateViewController() <UIAlertViewDelegate>
{
	CFTimeInterval		lastTime;
}

@property (nonatomic, strong) IBOutlet SNBAnnotateView *paintingView;
@property (nonatomic, strong) IBOutlet UIImageView *backgroundView;
@property (nonatomic, strong) IBOutlet UIButton *saveButton;
@property (nonatomic, strong) IBOutlet UIButton *cancelButton;
@property (nonatomic, strong) IBOutlet UIButton *undoButton;
@property (nonatomic, strong) IBOutlet UIButton *blurButton;
@property (nonatomic, strong) IBOutlet UISegmentedControl *colorSelector;
@property (nonatomic, strong) SNBStateDataItem *item;
@property (nonatomic, strong) IBOutlet UIView *actionPanel;
@property (nonatomic, strong) dispatch_queue_t imageOperationQueue;
@property (nonatomic, assign) BOOL hasBlurredImage;
@property (nonatomic, strong) UIImage *originalImage;


@end

@implementation SNBAnnotateViewController

- (instancetype)initWithDataItem:(SNBStateDataItem *)item;
{
    self = [super init];
    if(self) {
        self.item = item;
        self.originalImage = [item screenShot];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self.colorSelector removeAllSegments];
    [self.colorSelector insertSegmentWithImage:[[UIImage imageNamed:@"Purple"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] atIndex:0 animated:NO];
    [self.colorSelector insertSegmentWithImage:[[UIImage imageNamed:@"Blue"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] atIndex:0 animated:NO];
    [self.colorSelector insertSegmentWithImage:[[UIImage imageNamed:@"Green"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] atIndex:0 animated:NO];
    [self.colorSelector insertSegmentWithImage:[[UIImage imageNamed:@"Yellow"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] atIndex:0 animated:NO];
    [self.colorSelector insertSegmentWithImage:[[UIImage imageNamed:@"Red"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] atIndex:0 animated:NO];

    CGRect actionPanelFrame = self.actionPanel.bounds;
    actionPanelFrame.origin.y = CGRectGetMaxY(self.view.frame);
    self.actionPanel.frame = actionPanelFrame;
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGRect frame = CGRectMake(kLeftMargin, CGRectGetMinY(self.colorSelector.frame), rect.size.width - (kLeftMargin + kRightMargin), kPaletteHeight);
    self.colorSelector.frame = frame;
    
    // Make sure the color of the color complements the black background
    self.colorSelector.tintColor = [UIColor darkGrayColor];
    // Set the third color (index values start at 0)
    self.colorSelector.selectedSegmentIndex = 2;
    
    // Define a starting color
    CGColorRef color = [UIColor colorWithHue:(CGFloat)2.0 / (CGFloat)kPaletteSize
                                  saturation:kSaturation
                                  brightness:kBrightness
                                       alpha:1.0].CGColor;
    const CGFloat *components = CGColorGetComponents(color);
    
	// Defer to the OpenGL view to set the brush color
    [self.paintingView setStrokeColor:[UIColor colorWithRed:components[0] green:components[1] blue:components[2] alpha:1.0]];
    
    self.backgroundView.image = self.originalImage;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.paintingView.frame = self.view.bounds;
    self.backgroundView.frame = self.view.bounds;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIView animateWithDuration:0.3f animations:^{
        CGRect actionPanelFrame = self.actionPanel.frame;
        actionPanelFrame.origin.y = CGRectGetMaxY(self.view.frame) - CGRectGetHeight(self.actionPanel.bounds);
        self.actionPanel.frame = actionPanelFrame;
        
        CGRect paintingViewFrame = CGRectInset(self.view.bounds, 22, 22);
        paintingViewFrame.origin.y = 0;
        paintingViewFrame.origin.x = self.view.center.x - CGRectGetWidth(paintingViewFrame)/2;
        self.paintingView.frame = paintingViewFrame;
        self.backgroundView.frame = paintingViewFrame;
    } completion:^(BOOL finished) {
        if(finished) {
            [self.view insertSubview:self.paintingView aboveSubview:self.backgroundView];
            [self.paintingView becomeFirstResponder];
        }
    }];
    
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

// Release resources when they are no longer needed,
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// Change the brush color
- (IBAction)changeBrushColor:(id)sender
{
    // Define a new brush color
    CGColorRef color = [UIColor colorWithHue:(CGFloat)[sender selectedSegmentIndex] / (CGFloat)kPaletteSize
                                  saturation:kSaturation
                                  brightness:kBrightness
                                       alpha:1.0].CGColor;
    const CGFloat *components = CGColorGetComponents(color);
    
    // Defer to the OpenGL view to set the brush color
    [self.paintingView setStrokeColor:[UIColor colorWithRed:components[0] green:components[1] blue:components[2] alpha:1.0]];
}

// Called when receiving the "shake" notification; plays the erase sound and redraws the view
- (void)eraseView
{
	if(CFAbsoluteTimeGetCurrent() > lastTime + kMinEraseInterval) {
		[self.paintingView undoAll];
		lastTime = CFAbsoluteTimeGetCurrent();
	}
}

// We do not support auto-rotation in this sample
- (BOOL)shouldAutorotate
{
    return NO;
}

#pragma mark Motion

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        [self eraseView];
	}
}

- (void)dismiss
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (IBAction)doneButtonTapped:(id)sender
{
    if ([self.paintingView moreToUndo] || self.hasBlurredImage) {
        NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:appName message:@"Save changes?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [alertView show];
    } else {
        [self expandWithCompletion:^(BOOL finished) {
            if(finished) {
                [self dismiss];
            }
        }];
    }
}

- (IBAction)blurButtonTapped:(id)sender
{
    if(self.backgroundView.image == self.originalImage) {
        [self applyBlur];
    } else {
        [self removeBlur];
    }
}

- (void)applyBlur
{
    self.hasBlurredImage = YES;
    self.blurButton.selected = YES;
    [self disableUserInterface];
    
    UIImage *originalImage = [self.backgroundView.image copy];
    dispatch_async(self.imageOperationQueue, ^{
        UIImage *blurImage = [originalImage blurWithBottomInset:0 blurRadius:5];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImageView *blurImageView = [[UIImageView alloc] initWithImage:blurImage];
            blurImageView.autoresizingMask = self.backgroundView.autoresizingMask;
            blurImageView.backgroundColor = self.backgroundView.backgroundColor;
            blurImageView.contentMode = self.backgroundView.contentMode;
            blurImageView.frame = self.backgroundView.frame;
            blurImageView.userInteractionEnabled = NO;
            
            [UIView transitionFromView:self.backgroundView toView:blurImageView duration:0.5f options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
                if(finished) {
                    [self.backgroundView removeFromSuperview];
                    self.backgroundView = blurImageView;
                    [self enableUserInterface];
                }
            }];
        });
    });
}

- (void)removeBlur
{
    self.hasBlurredImage = NO;
    self.blurButton.selected = NO;
    [self disableUserInterface];
    
    dispatch_async(self.imageOperationQueue, ^{
        UIImage *blurImage = self.originalImage;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImageView *blurImageView = [[UIImageView alloc] initWithImage:blurImage];
            blurImageView.autoresizingMask = self.backgroundView.autoresizingMask;
            blurImageView.backgroundColor = self.backgroundView.backgroundColor;
            blurImageView.contentMode = self.backgroundView.contentMode;
            blurImageView.frame = self.backgroundView.frame;
            blurImageView.userInteractionEnabled = NO;
            
            [UIView transitionFromView:self.backgroundView toView:blurImageView duration:0.5f options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
                if(finished) {
                    [self.backgroundView removeFromSuperview];
                    self.backgroundView = blurImageView;
                    [self enableUserInterface];
                }
            }];
        });
    });
}

- (void)disableUserInterface
{
    self.view.userInteractionEnabled = NO;
}

- (void)enableUserInterface
{
    self.view.userInteractionEnabled = YES;
}

- (dispatch_queue_t)imageOperationQueue
{
    if(!_imageOperationQueue) {
        _imageOperationQueue = dispatch_queue_create([GCDAsyncSNBAnnotateQueueName UTF8String], DISPATCH_QUEUE_CONCURRENT);
    }
    return _imageOperationQueue;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0) {
        [self expandWithCompletion:^(BOOL finished) {
            if(finished) {
                [self dismiss];
            }
        }];
    } else if(buttonIndex == 1) {
        [self saveAnnotation];
    }
}

- (void)saveAnnotation
{
    [self expandWithCompletion:^(BOOL finished) {
        if(finished) {
            SNBStateDataItem *item = [self.item copy];
            NSString *viewControllerName = [item viewControllerName];
            NSString *annotatedViewControllerName = (viewControllerName) ? [NSString stringWithFormat:@"%@ (Edited)", viewControllerName] : @"-- Edited --";
            [item updateValue:annotatedViewControllerName forKey:kSNBKeyClass];
            
            [[SynUserMock sharedInstance] saveStateWithData:item afterScreenUpdate:YES completion:^{
                [self dismiss];
            }];
        }
    }];
}

- (void)expandWithCompletion:(void (^)(BOOL finished))completion
{
    [UIView animateWithDuration:0.15f animations:^{
        CGRect actionPanelFrame = self.actionPanel.frame;
        actionPanelFrame.origin.y = CGRectGetMaxY(self.view.frame) + 1;
        self.actionPanel.frame = actionPanelFrame;
        
        self.backgroundView.frame = self.view.bounds;
        self.paintingView.frame = self.view.bounds;
    } completion:^(BOOL finished) {
        if(finished) {
            if(completion != NULL) {
                completion(finished);
            }
        }
    }];
}

- (IBAction)undoButtonTapped:(id)sender
{
    if ([self.paintingView moreToUndo]) {
        [self.paintingView undo];
    }
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
