/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import "SNBStateDataStoryBoard.h"
#import "SNBStateDataItem.h"
#import "SynUserMock.h"
#import "SynUserMock_private.h"

static NSString *touchImageFilename = @"SNBTapGesture.png";
static const CGFloat screenShotScalFactor = 1.0f;
static const CGPoint touchOffset = (CGPoint) {18.0f, 18.0f};
static CGSize screenShotSize;
static CGRect screenShotRect;

static inline double radians (double degrees) {return degrees * M_PI/180;}

@implementation SNBStateDataStoryBoard

static CGFloat kSNBDefaultBlurRadius = 5.0f;

+ (void)initialize
{
    UIWindow *view = [UIApplication sharedApplication].keyWindow;
    screenShotSize = CGSizeMake(CGRectGetWidth(view.bounds)*screenShotScalFactor, CGRectGetHeight(view.bounds)*screenShotScalFactor);
    screenShotRect = (CGRect) {CGPointZero, screenShotSize};
}

- (UIImage *)screenShotWithItem:(SNBStateDataItem *)item afterScreenUpdate:(BOOL)afterScreenUpdate
{
    @autoreleasepool {
        
        CGSize imageSize = CGSizeZero;
        UIImage *image = nil;
        
        UIInterfaceOrientation orientation = ([[[UIDevice currentDevice] systemVersion] compare:@"8" options:NSNumericSearch] != NSOrderedAscending) ? UIInterfaceOrientationPortrait : [[UIApplication sharedApplication] statusBarOrientation];
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            imageSize = [UIScreen mainScreen].bounds.size;
        } else {
            imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
        }
        imageSize = CGSizeMake(imageSize.width * screenShotScalFactor, imageSize.height * screenShotScalFactor);
        
        UIGraphicsBeginImageContextWithOptions(imageSize, YES, 1.0f);  //[[UIScreen mainScreen] scale]
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        
        if(context != NULL && window != nil) {
            
            CGContextTranslateCTM(context, window.center.x, window.center.y);
            CGContextConcatCTM(context, window.transform);
            CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
            if (orientation == UIInterfaceOrientationLandscapeLeft) {
                CGContextRotateCTM(context, M_PI_2);
                CGContextTranslateCTM(context, 0, -imageSize.width);
            } else if (orientation == UIInterfaceOrientationLandscapeRight) {
                CGContextRotateCTM(context, -M_PI_2);
                CGContextTranslateCTM(context, -imageSize.height, 0);
            } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
                CGContextRotateCTM(context, M_PI);
                CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
            }
            
            CGContextConcatCTM(context, CGAffineTransformMakeScale(screenShotScalFactor,screenShotScalFactor));
           
            if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
                [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:afterScreenUpdate];
            } else {
                [window.layer renderInContext:context];
            }
            
            if(item && !CGPointEqualToPoint(item.touchPoint, CGPointZero)) {
                
                UIImage *touchImage = [UIImage imageNamed:touchImageFilename];
                CGPoint position = [item touchPoint];
                
                UIImageOrientation  imageOrientation = [self touchPointImageForRect:screenShotRect withTouchPoint:position];
                CGPoint imagePosition = [self imagePositionForOrientation:imageOrientation imageSize:touchImage.size touchPoint:position];
                
                if(imageOrientation != UIImageOrientationUp) {
                    touchImage = [UIImage imageWithCGImage:touchImage.CGImage scale:touchImage.scale orientation:imageOrientation];
                }
                
                [touchImage drawAtPoint:imagePosition];
            }
            
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
            
#if DEBUG
            NSAssert(context != NULL, @"SNB - Context is NULL");
            NSAssert(window != nil, @"SNB - view is nil.");
#endif
        
        // Blur image if needed
        if([[SynUserMock sharedInstance].delegate respondsToSelector:@selector(synUserMockShouldBlurScreenShotOfViewControllerForClass:)]) {
            NSString *viewControllerClassName = item.data[kSNBKeyClass];
            if(viewControllerClassName && NSClassFromString(viewControllerClassName)) {
                Class viewControllerClass = NSClassFromString(viewControllerClassName);
                if([[SynUserMock sharedInstance].delegate synUserMockShouldBlurScreenShotOfViewControllerForClass:viewControllerClass]) {
                    CGFloat blurRadius = kSNBDefaultBlurRadius;
                    if([[SynUserMock sharedInstance].delegate respondsToSelector:@selector(synUserMockBlurRadiusForClass:)]) {
                        blurRadius = [[SynUserMock sharedInstance].delegate synUserMockBlurRadiusForClass:viewControllerClass];
                    }                    
                    image = [self blurImage:image withBottomInset:0 blurRadius:blurRadius];
                }
            }
        }

        return image;
    }
}


- (UIImage*)blurImage:(UIImage *)image withBottomInset:(CGFloat)inset blurRadius:(CGFloat)radius
{
    CIImage *ciImage = [CIImage imageWithCGImage:image.CGImage];
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:ciImage forKey:kCIInputImageKey];
    [filter setValue:@(radius) forKey:kCIInputRadiusKey];
    
    CIImage *outputCIImage = filter.outputImage;
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CGImageRef contextImage = [context createCGImage:outputCIImage fromRect:ciImage.extent];
    UIImage *blurredImage = [UIImage imageWithCGImage: contextImage];
    CFRelease(contextImage);
    
    return blurredImage;
}


- (CGPoint)imagePositionForOrientation:(UIImageOrientation)imageOrientation imageSize:(CGSize)imageSize touchPoint:(CGPoint)touchPoint
{
    CGPoint imagePosition = CGPointZero;
    switch (imageOrientation) {
        case UIImageOrientationUp:
            imagePosition = CGPointMake((touchPoint.x * screenShotScalFactor) - (imageSize.width * 0.5f) + touchOffset.x,
                                         (touchPoint.y * screenShotScalFactor) - (imageSize.height * 0.5f) + touchOffset.y);
            break;
            
        case UIImageOrientationUpMirrored:
            imagePosition = CGPointMake((touchPoint.x * screenShotScalFactor) - (imageSize.width * 0.5f) - touchOffset.x,
                                         (touchPoint.y * screenShotScalFactor) - (imageSize.height * 0.5f) + touchOffset.y);
            break;
            
        case UIImageOrientationDown:
            imagePosition = CGPointMake((touchPoint.x * screenShotScalFactor) - (imageSize.width * 0.5f) - touchOffset.x,
                                         (touchPoint.y * screenShotScalFactor) - (imageSize.height * 0.5f) - touchOffset.y);
            break;
            
        case UIImageOrientationDownMirrored:
            imagePosition = CGPointMake((touchPoint.x * screenShotScalFactor) - (imageSize.width * 0.5f) + touchOffset.x,
                                         (touchPoint.y * screenShotScalFactor) - (imageSize.height * 0.5f) - touchOffset.y);
            break;
            
        default: break;
    }
    return imagePosition;
}

- (UIImageOrientation)touchPointImageForRect:(CGRect)rect withTouchPoint:(CGPoint)touchPoint
{
    // calculate normal position
    UIImage *touchImage = [UIImage imageNamed:touchImageFilename];
    CGSize touchSize = CGSizeMake(touchImage.size.width*0.5f, touchImage.size.height*0.5f);
    CGPoint normalPoint = CGPointMake((touchPoint.x * screenShotScalFactor) - touchSize.width + touchOffset.x,
                                         (touchPoint.y * screenShotScalFactor) - touchSize.height + touchOffset.y);
    
    UIImageOrientation imageOrientation = UIImageOrientationUp;
    
    // extends off right side of the screen and past the bottom of the screen
    if(normalPoint.x + touchImage.size.width > CGRectGetMaxX(rect) && normalPoint.y + touchImage.size.height > CGRectGetMaxY(rect)) {
        imageOrientation = UIImageOrientationDown;
    }
    
    // extends off right side of the screen
    else if(normalPoint.x + touchImage.size.width > CGRectGetMaxX(rect)) {
        imageOrientation = UIImageOrientationUpMirrored;
    }
    
    // extends past the bottom of the screen
    else if(normalPoint.y + touchImage.size.height > CGRectGetMaxY(rect)) {
        imageOrientation = UIImageOrientationDownMirrored;
    }
    
    return imageOrientation;
}

- (UIImage *)rotateForDeviceOrientation:(UIImage *)image
{
    UIImage *finalImage = image;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (orientation == UIInterfaceOrientationLandscapeLeft) {
        finalImage = rotatedImage(image, radians(90));
    } else if (orientation == UIInterfaceOrientationLandscapeRight) {
        finalImage = rotatedImage(image, radians(-90));
    } else if (orientation == UIInterfaceOrientationPortrait) {
        // do nothing
    } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        finalImage = rotatedImage(image, radians(180));
    }
    
    return finalImage;
}

UIImage *rotatedImage(UIImage *image, CGFloat rotation)
{
    // Calculate Destination Size
    CGAffineTransform t = CGAffineTransformMakeRotation(rotation);
    CGRect sizeRect = (CGRect) {.size = image.size};
    CGRect destRect = CGRectApplyAffineTransform(sizeRect, t);
    CGSize destinationSize = destRect.size;
    
    // Draw image
    UIGraphicsBeginImageContext(destinationSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, destinationSize.width / 2.0f, destinationSize.height / 2.0f);
    CGContextRotateCTM(context, rotation);
    [image drawInRect:CGRectMake(-image.size.width / 2.0f, -image.size.height / 2.0f, image.size.width, image.size.height)];
    
    // Save image
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

- (NSData *)stateWithItem:(SNBStateDataItem *)item afterScreenUpdate:(BOOL)afterScreenUpdate
{
    UIImage *screenShot = [self screenShotWithItem:item afterScreenUpdate:afterScreenUpdate];
    NSData *data = nil;
    if(screenShot) {
        data = UIImageJPEGRepresentation(screenShot, 0.5f);
    }
    
    return data;
}

@end
