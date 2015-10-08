//
//  XImageView.h
//  XFramework
//
//  Created by XJY on 15-7-26.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XImageView : UIImageView

@property (nonatomic) UIImage *normalImage;
@property (nonatomic) UIImage *highlightImage;
@property (nonatomic) UIImage *selectedImage;

@end

@interface UIImageView (X_ImageView)

- (void)x_setTintColor:(UIColor *)tintColor;

@end