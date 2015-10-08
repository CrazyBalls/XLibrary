//
//  XTool.h
//  XFramework
//
//  Created by XJY on 15-7-26.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//调试输出Log
#ifdef DEBUG
    #define debugLog(...) NSLog(__VA_ARGS__)
    #define debugMethod() NSLog(@"%s", __func__)
#else
    #define debugLog(...)
    #define debugMethod()
#endif

//在主线程同步执行语句块
#define x_dispatch_main_sync(block)\
                                if ([NSThread isMainThread]) {\
                                    block();\
                                } else {\
                                    dispatch_sync(dispatch_get_main_queue(), block);\
                                }

//异步到主线程执行语句块
#define x_dispatch_main_async(block)\
                                if ([NSThread isMainThread]) {\
                                    block();\
                                } else {\
                                    dispatch_async(dispatch_get_main_queue(), block);\
                                }

//创建子线程，默认优先级
#define x_dispatch_async_default(block)\
                                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);

//状态栏高度,根据系统版本决定.IOS7及以上,状态栏高度为20,否则为0
#define statusBarHeight 20.0f
#define statusBarOriginY ((floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) ? statusBarHeight : 0.0f)//因为是宏替换,而且?的优先级比较低,因此需要加个括号保证?先执行
#define navigationBarHeight 44

//tag的起始值
#define initializeTag 1000

//字体
#define helveticaFontWithSize(fontSize)             [UIFont fontWithName:@"Helvetica" size:fontSize]
#define helveticaBoldFontWithSize(fontSize)         [UIFont fontWithName:@"Helvetica-Bold" size:fontSize]
#define helveticaObliqueFontWithSize(fontSize)      [UIFont fontWithName:@"Helvetica-Oblique" size:fontSize]
#define helveticaBoldObliqueFontWithSize(fontSize)  [UIFont fontWithName:@"Helvetica-BoldOblique" size:fontSize]

@interface XTool : NSObject

/**
 判断字符串是否为空
 */
+ (BOOL)isStringEmpty:(NSString *)str;

/**
 判断数组是否为空
 */
+ (BOOL)isArrayEmpty:(NSArray *)array;

/**
 判断字典是否为空
 */
+ (BOOL)isDictionaryEmpty:(NSDictionary *)dictionary;

/**
 判断NSData是否为空
 */
+ (BOOL)isDataEmpty:(NSData *)data;

/**
 获取当前时间
 */
+ (NSString *)getCurrentTime:(NSString *)dateFormat;

/**
 获取当前app版本
 */
+ (NSString *)getCurrentAppVersion;

/**
 检查邮箱是否合法
 */
+ (BOOL)isValidateEmail:(NSString *)email;

/**
 检查手机号是否合法
 */
+ (BOOL)isValidateMobile:(NSString *)mobileNum;

/**
 设置角标
 */
+ (void)setApplicationIconBadgeNumber:(NSInteger)badgeNumber;

/**
 在主线程发送通知
 */
+ (void)sendNotificationOnMainThread:(NSString *)notificationName withObject:(id)object;

/**
 在当前线程发送通知
 */
+ (void)sendNotification:(NSString *)notificationName withObject:(id)object;

/**
 根据文字和字体获取label的大小
 */
+ (CGSize)labelSize:(NSString *)text font:(UIFont *)font;

/**
 根据文字和字体以及允许的最大大小获取label的大小
 */
+ (CGSize)labelSize:(NSString *)text font:(UIFont *)font maximumSize:(CGSize)maximumSize;

/**
 根据文字和字体以及宽度获取高度
 */
+ (CGFloat)heightForText:(NSString *)text font:(UIFont *)font width:(CGFloat)width;

/**
 根据文字,字体,宽度以及允许的最大高度获取高度
 */
+ (CGFloat)heightForText:(NSString *)text font:(UIFont *)font width:(CGFloat)width maxHeight:(CGFloat)maxHeight;

/**
 根据文字,字体,高度获取宽度
 */
+ (CGFloat)widthForText:(NSString *)text font:(UIFont *)font height:(CGFloat)height;

/**
 根据文字,字体,高度以及允许的最大宽度获取宽度
 */
+ (CGFloat)widthForText:(NSString *)text font:(UIFont *)font height:(CGFloat)height maxWidth:(CGFloat)maxWidth;

/**
 字符转字符串
 */
+ (NSString *)charToString:(char *)c;

/**
 防止viewcontroller被导航栏挡住
 */
+ (void)preventShelteredFromNavigationBarForViewController:(UIViewController *)viewController;

/**
 判断app是否第一次运行
 */
+ (BOOL)appNotFirstLaunch;

/**
 获取App名称
 */
+ (NSString *)getAppName;

/**
 获取颜色的RGB值
 返回CGFloat数组, 0是R, 1是G, 2是B
 */
+ (const CGFloat *)getRGBFromColor:(UIColor *)color;

/**
 获取颜色的alpha值
 如果color为空, 则返回-1
 */
+ (CGFloat)getAlphaFromColor:(UIColor *)color;

/**
 旋转指定角度
 */
+ (CGAffineTransform)rotationWithAngle:(CGFloat)angle;

/**
 base64编码, 返回NSString
 */
+ (NSString *)base64EncodedStringWithData:(NSData *)data;

/**
 base64解码, 返回NSData
 */
+ (NSData *)base64DecodedDataWithString:(NSString *)base64String;

@end
