//
//  XAlert.h
//  XFramework
//
//  Created by XJY on 15-7-28.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

@interface XAlert : NSObject

/**
 只弹出文字以及一个按钮
 */
+ (void)alertOnlyText:(NSString *)text buttonText:(NSString *)buttonText;

/**
 只弹出文字,最多支持一行
 */
+ (void)progressOnlyShowText:(MBProgressHUD *)hud text:(NSString *)text;

/**
 只弹出文字,最多支持两行
 */
+ (void)progressShowMoreText:(MBProgressHUD *)hud text:(NSString *)text detailsText:(NSString *)detailsText;

/**
 弹出图片及文字
 */
+ (void)progressShowImageAndText:(MBProgressHUD *)hud text:(NSString *)text image:(UIImage *)image;

@end
