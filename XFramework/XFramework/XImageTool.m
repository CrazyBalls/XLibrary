//
//  XImageTool.m
//  XFramework
//
//  Created by XJY on 15-7-26.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import "XImageTool.h"
#import "XTool.h"
#import "XFileManager.h"

@implementation XImageTool

+ (UIImage *)initImageWithContentsOfName:(NSString *)imageName {
    if ([XTool isStringEmpty:imageName] == YES) {
        return nil;
    } else {
        UIImage *image = nil;
        if ([imageName rangeOfString:@"."].location == NSNotFound) {
            image = [self initImageWithContentsOfName:imageName type:@"png"];
            if (image == nil) {
                image = [self initImageWithContentsOfName:imageName type:@"jpg"];
            }
            if (image == nil) {
                image = [self initImageWithContentsOfName:imageName type:@"jpeg"];
            }
            if (image == nil) {
                image = [self initImageWithContentsOfName:imageName type:@"bmp"];
            }
        } else {
            NSString *name = [XFileManager getFileNameWithoutSufixForName:imageName];
            NSString *type = [XFileManager getSufixForName:imageName];
            image = [self initImageWithContentsOfName:name type:type];
        }
        return image;
    }
}

+ (UIImage *)imageWithContentsOfName:(NSString *)imageName {
    if ([XTool isStringEmpty:imageName] == YES) {
        return nil;
    } else {
        UIImage *image = nil;
        if ([imageName rangeOfString:@"."].location == NSNotFound) {
            image = [self imageWithContentsOfName:imageName type:@"png"];
            if (image == nil) {
                image = [self imageWithContentsOfName:imageName type:@"jpg"];
            }
            if (image == nil) {
                image = [self imageWithContentsOfName:imageName type:@"jpeg"];
            }
            if (image == nil) {
                image = [self imageWithContentsOfName:imageName type:@"bmp"];
            }
        } else {
            NSString *name = [XFileManager getFileNameWithoutSufixForName:imageName];
            NSString *type = [XFileManager getSufixForName:imageName];
            image = [self imageWithContentsOfName:name type:type];
        }
        return image;
    }
}

+ (UIImage *)initImageWithContentsOfName:(NSString *)imageName type:(NSString *)type {
    if ([XTool isStringEmpty:imageName] == YES) {
        return nil;
    } else {
        NSString *imagePath = [XFileManager getBundleResourcePathWithName:imageName type:type];
        return [[UIImage alloc] initWithContentsOfFile:imagePath];
    }
}

+ (UIImage *)imageWithContentsOfName:(NSString *)imageName type:(NSString *)type {
    if ([XTool isStringEmpty:imageName] == YES) {
        return nil;
    } else {
        NSString *imagePath = [XFileManager getBundleResourcePathWithName:imageName type:type];
        return [UIImage imageWithContentsOfFile:imagePath];
    }
}

+ (UIImage *)imageNamed:(NSString *)imageName {
    if ([XTool isStringEmpty:imageName] == YES) {
        return nil;
    } else {
        return [UIImage imageNamed:imageName];
    }
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theImage;
}

+ (UIImage *)fixOrientation:(UIImage *)aImage {
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

+ (NSData *)changeImageSize:(UIImage*)sourceImage scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [sourceImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return UIImageJPEGRepresentation(newImage, 0.8);
}

+ (NSData *)compressWithSourceImage:(UIImage *)sourceImage targetImageLength:(CGFloat)targetImageLength {
    NSData *compressedImageData = UIImagePNGRepresentation(sourceImage);
    UIImage *compressedImage = [UIImage imageWithData:compressedImageData];
    CGFloat compressedScale = 75 * 1.0 / 100;
    while (compressedImageData.length > targetImageLength) {
        CGFloat newImageWidth = compressedImage.size.width * compressedScale;
        CGFloat newImageHeight = compressedImage.size.height * compressedScale;
        compressedImageData = [self changeImageSize:compressedImage scaledToSize:CGSizeMake(newImageWidth, newImageHeight)];
        compressedImage = [UIImage imageWithData:compressedImageData];
    }
    return compressedImageData;
}

+ (NSData *)dataWithImage:(UIImage *)image {
    if (image == nil) {
        return nil;
    }
    return UIImagePNGRepresentation(image);
}

@end
