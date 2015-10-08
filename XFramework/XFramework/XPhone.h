//
//  XPhone.h
//  XFramework
//
//  Created by XJY on 15-7-28.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface XPhone : NSObject

/**
 电话号码转换为E164格式
 */
+ (NSString *)phoneNumberWithFormatE164:(NSString *)phoneNumber;

/**
 获取电话接口地址
 */
+ (NSURL *)getTelUrl:(NSString *)phoneNumber;

/**
 获取发送短信接口地址
 */
+ (NSURL *)getSmsUrl:(NSString *)phoneNumber;

/**
 打电话,通话结束后不可返回
 */
+ (void)callTelephone:(NSString *)phoneNumber;

/**
 打电话,通话结束后可返回,通过UIWebview实现
 */
+ (void)callTelephone:(NSString *)phoneNumber atSuper:(UIView *)superView;

/**
 发短信
 */
+ (void)sendSms:(NSString *)phoneNumber;

/**
 调用默认邮箱客户端
 */
+ (void)openEmail:(NSString *)email;

/**
 调用默认浏览器
 */
+ (void)openBrowserWithString:(NSString *)urlStr;

+ (void)openBrowserWithUrl:(NSURL *)url;

/**
 获取通讯录
 */
+ (void)getContact:(void (^)(NSArray *contacts))block;

@end
