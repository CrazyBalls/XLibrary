//
//  XGalleryCell.m
//  XFramework
//
//  Created by XJY on 15-7-31.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import "XGalleryCell.h"
#import "UIImageView+WebCache.h"
#import "UIImage+GIF.h"
#import "XFileManager.h"
#import "XTool.h"
#import "XImageTool.h"

NSString *const galleryCellIdentifier = @"galleryCell";

@interface XGalleryCell() <UIScrollViewDelegate> {
    UIScrollView    *   imageScrollView;
    UIImageView     *   imageView;
}

@end

@implementation XGalleryCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    [self setBackgroundColor:[UIColor clearColor]];
    [self.contentView setBackgroundColor:[UIColor clearColor]];
    
    _placeholderImageName = @"";
    _maximumZoomScale = 2.0;
    _minimumZoomScale = 1.0;
}

- (void)addImageScrollView {
    imageScrollView = [[UIScrollView alloc] init];
    [imageScrollView setBackgroundColor:[UIColor clearColor]];
    [imageScrollView setShowsHorizontalScrollIndicator:NO];
    [imageScrollView setShowsVerticalScrollIndicator:NO];
    [imageScrollView setPagingEnabled:NO];
    [imageScrollView setDelegate:self];
    [imageScrollView setBounces:YES];
    [imageScrollView setClipsToBounds:YES];
    [imageScrollView setDelaysContentTouches:NO];
    [imageScrollView setHidden:NO];
    [imageScrollView setBouncesZoom:YES];
    [imageScrollView setMaximumZoomScale:_maximumZoomScale];
    [imageScrollView setMinimumZoomScale:_minimumZoomScale];
    [imageScrollView setClipsToBounds:YES];
    [self.contentView addSubview:imageScrollView];
}

- (void)updateScrollViewFrame {
    CGFloat scrollViewWidth = self.contentView.frame.size.width;
    CGFloat scrollViewHeight = self.contentView.frame.size.height;
    CGFloat scrollViewX = 0;
    CGFloat scrollViewY = 0;
    [imageScrollView setFrame:CGRectMake(scrollViewX, scrollViewY, scrollViewWidth, scrollViewHeight)];
    [imageScrollView setContentSize:CGSizeMake(scrollViewWidth, scrollViewHeight)];
    [imageScrollView setContentOffset:CGPointMake(0, 0)];
}

- (void)addImageView {
    imageView = [[UIImageView alloc] init];
    [imageView setUserInteractionEnabled:YES];
    [imageScrollView addSubview:imageView];
}

- (void)updateImageViewFrame {
    CGFloat imageViewWidth = 0;
    CGFloat imageViewHeight = 0;
    CGFloat imageViewX = 0;
    CGFloat imageViewY = 0;
    
    CGFloat imageWidth = 0;
    CGFloat imageHeight = 0;
    if (imageView != nil && imageView.image != nil) {
        imageWidth = imageView.image.size.width;
        imageHeight = imageView.image.size.height;
    }
    if (imageWidth <= 0 || imageHeight <= 0) {
        imageViewWidth = 0;
        imageViewHeight = 0;
        imageViewX = 0;
        imageViewY = 0;
    } else {
        CGFloat scrollViewWidth = imageScrollView.frame.size.width;
        CGFloat scrollViewHeight = imageScrollView.frame.size.height;
        
        CGFloat widthScale = imageWidth*1.0/scrollViewWidth;
        CGFloat HeightScale = imageHeight*1.0/scrollViewHeight;
        CGFloat imageSizeScale = imageWidth * 1.0 / imageHeight;
        
        if (widthScale <= 1.0 && HeightScale <= 1.0) {
            imageViewWidth = imageWidth;
            imageViewHeight = imageHeight;
            imageViewX = (scrollViewWidth - imageViewWidth) * 1.0 / 2;
            imageViewY = (scrollViewHeight - imageViewHeight) * 1.0 / 2;
        } else {
            if (widthScale >= HeightScale) {
                imageViewWidth = scrollViewWidth;
                imageViewHeight = imageViewWidth * 1.0 / imageSizeScale;
                imageViewX = 0;
                imageViewY = (scrollViewHeight - imageViewHeight) * 1.0 / 2;
            } else {
                imageViewHeight = scrollViewHeight;
                imageViewWidth = imageViewHeight * imageSizeScale;
                imageViewX = (scrollViewWidth - imageViewWidth) * 1.0 / 2;
                imageViewY = 0;
            }
        }
    }

    [imageView setFrame:CGRectMake(imageViewX, imageViewY, imageViewWidth, imageViewHeight)];
}

- (void)setMaximumZoomScale:(CGFloat)maximumZoomScale {
    _maximumZoomScale = maximumZoomScale;
    [imageScrollView setMaximumZoomScale:_maximumZoomScale];
}

- (void)setMinimumZoomScale:(CGFloat)minimumZoomScale {
    _minimumZoomScale = minimumZoomScale;
    [imageScrollView setMinimumZoomScale:_minimumZoomScale];
}

- (void)addUI {
    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }
    [self.contentView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self addImageScrollView];
    [self addImageView];
    [self updateScrollViewFrame];
    [self updateImageViewFrame];
}

- (void)addImageForName:(NSString *)imageName {
    [self addUI];
    
    UIImage *image = nil;
    NSString *name = @"";
    NSString *type = @"";
    if ([XTool isStringEmpty:imageName] == NO) {
        name = [XFileManager getFileNameWithoutSufixForName:imageName];
        type = [XFileManager getSufixForName:imageName];
        
        if ([XTool isStringEmpty:name] == NO) {
            if ([XTool isStringEmpty:type] == NO) {
                image = [XImageTool initImageWithContentsOfName:name type:type];
            } else {
                image = [XImageTool initImageWithContentsOfName:name];
            }
        }
    }
    [self addImage:image];
}

- (void)addImageForPath:(NSString *)imagePath {
    [self addUI];
    
    UIImage *image = nil;
    if ([XTool isStringEmpty:imagePath] == NO) {
        image = [[UIImage alloc] initWithContentsOfFile:imagePath];
    }
    [self addImage:image];
}

- (void)addImageForUrl:(NSString *)imageUrl placeHolderImageName:(NSString *)placeHolderImageName {
    [self addUI];
    
    UIActivityIndicatorView *loading = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [loading setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    [loading setCenter:self.contentView.center];
    [self.contentView addSubview:loading];
    [loading startAnimating];
    
    __block XGalleryCell *b_Self = self;
    [imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:placeHolderImageName] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [loading stopAnimating];
        [b_Self updateImageViewFrame];
    }];
}

- (void)addImageForData:(NSData *)data {
    [self addUI];
    
    UIImage *image = nil;
    if (data != nil) {
        image = [UIImage imageWithData:data];
    }
    [self addImage:image];
}

- (void)addGifForName:(NSString *)name {
    [self addUI];
    
    UIImage *image = [UIImage sd_animatedGIFNamed:name];
    [self addImage:image];
}

- (void)addGifForPath:(NSString *)gifPath {
    [self addUI];
    
    NSString *gifName = [XFileManager getFileNameWithoutSufixForPath:gifPath];
    if ([XTool isStringEmpty:gifName] == NO)  {
        [self addGifForName:gifName];
    } else {
        [self addImage:nil];
    }
}

- (void)addGifForData:(NSData *)data {
    [self addUI];
    
    UIImage *image = nil;
    if (data != nil) {
        image = [UIImage sd_animatedGIFWithData:data];
    }
    [self addImage:image];
}

- (void)addImage:(UIImage *)image {
    if (image == nil) {
        image = [XImageTool initImageWithContentsOfName:_placeholderImageName];
    }
    [imageView setImage:image];
    [self updateImageViewFrame];
}

- (void)setImageViewToCenter:(UIScrollView *)scrollView {
    CGFloat imageViewX = 0;
    CGFloat imageViewY = 0;
    if (imageView.frame.size.width < scrollView.frame.size.width) {
        imageViewX = (scrollView.frame.size.width - imageView.frame.size.width)*1.0/2;
    } else {
        imageViewX = 0;
    }
    if (imageView.frame.size.height < scrollView.frame.size.height) {
        imageViewY = (scrollView.frame.size.height - imageView.frame.size.height)*1.0/2;
    } else {
        imageViewY = 0;
    }
    
    CGRect imageViewFrame = imageView.frame;
    imageViewFrame.origin.x = imageViewX;
    imageViewFrame.origin.y = imageViewY;
    [imageView setFrame:imageViewFrame];
}

#pragma mark UIScrollView Delegate Method

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self setImageViewToCenter:scrollView];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    [self setImageViewToCenter:scrollView];
}

@end
