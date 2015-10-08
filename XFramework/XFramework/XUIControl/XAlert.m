//
//  XAlert.m
//  XFramework
//
//  Created by XJY on 15-7-28.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import "XAlert.h"
#import <UIKit/UIAlertView.h>

@implementation XAlert

+ (void)alertOnlyText:(NSString *)text buttonText:(NSString *)buttonText {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:text message:nil delegate:nil cancelButtonTitle:buttonText otherButtonTitles:nil, nil];
    [alertView show];
}

+ (void)progressOnlyShowText:(MBProgressHUD *)hud text:(NSString *)text {
    [hud show:YES];
    [hud setMode:MBProgressHUDModeText];
    [hud setLabelText:text];
    [hud setMargin:10.f];
    [hud hide:YES afterDelay:1.0];
}

+ (void)progressShowMoreText:(MBProgressHUD *)hud text:(NSString *)text detailsText:(NSString *)detailsText {
    [hud show:YES];
    [hud setMode:MBProgressHUDModeText];
    [hud setLabelText:text];
    [hud setDetailsLabelText:detailsText];
    [hud setMargin:10.f];
    [hud hide:YES afterDelay:1.0];
}

+ (void)progressShowImageAndText:(MBProgressHUD *)hud text:(NSString *)text image:(UIImage *)image {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [hud setCustomView:imageView];
    [hud setMode:MBProgressHUDModeCustomView];
    [hud setLabelText:text];
    [hud hide:YES afterDelay:1.0];
}

@end
