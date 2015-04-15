/*
 * Copyright 2015, Yahoo Inc.
 * Copyrights licensed under the MIT License.
 * See the accompanying LICENSE file for terms.
 */

#import "UIImage+SNB.h"

@implementation UIImage (SNB)

- (UIImage *)blurWithBottomInset:(CGFloat)inset blurRadius:(CGFloat)radius
{
    CIImage *ciImage = [CIImage imageWithCGImage:self.CGImage];
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

@end
