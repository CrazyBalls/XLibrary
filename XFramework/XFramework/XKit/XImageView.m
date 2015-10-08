//
//  XImageView.m
//  XFramework
//
//  Created by XJY on 15-7-26.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import "XImageView.h"

@implementation XImageView


@end

#import "XIOSVersion.h"

@implementation UIImageView (X_ImageView)

- (void)x_setTintColor:(UIColor *)tintColor {
    if ([XIOSVersion isIOS7OrGreater] == YES) {
        [self setTintColor:tintColor];
    }
}

@end