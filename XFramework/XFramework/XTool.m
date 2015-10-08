//
//  XTool.m
//  XFramework
//
//  Created by XJY on 15-7-26.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import "XTool.h"
#import "XFileManager.h"
#import "XIOSVersion.h"
#import "Base64.h"
#import "XFoundation.h"

@implementation XTool

+ (BOOL)isStringEmpty:(NSString *)str {
    if(str != NULL && str && [str isEqualToString:@""] == NO && str.length > 0) {
        return NO;
    } else {
        return YES;
    }
}

+ (BOOL)isArrayEmpty:(NSArray *)array {
    if (array != nil && array.count > 0) {
        return NO;
    } else {
        return YES;
    }
}

+ (BOOL)isDictionaryEmpty:(NSDictionary *)dictionary {
    if (dictionary != nil && dictionary.count > 0) {
        return NO;
    } else {
        return YES;
    }
}

+ (BOOL)isDataEmpty:(NSData *)data {
    if (data != nil && data.length > 0) {
        return NO;
    } else {
        return YES;
    }
}

+ (NSString *)getCurrentTime:(NSString *)dateFormat {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:dateFormat];
    NSString *time = [formatter stringFromDate:[NSDate date]];
    return time;
}

+ (NSString *)getCurrentAppVersion {
    NSString *plistPath = [XFileManager getBundleResourcePathWithName:@"Info" type:@"plist"];
    NSDictionary *plistDic = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    NSString *currentVersion = [plistDic objectForKey:@"CFBundleShortVersionString"];
    return currentVersion;
}

+ (BOOL)isValidateEmail:(NSString *)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",emailRegex];
    return [emailTest evaluateWithObject:email];
}

+ (BOOL)isValidateMobile:(NSString *)mobileNum {
    /**
     * 手机号码
     * 移动:134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通:130,131,132,152,155,156,185,186
     * 电信:133,1349,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    /**
     10         * 中国移动:China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    /**
     15         * 中国联通:China Unicom
     16         * 130,131,132,152,155,156,185,186
     17         */
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
     20         * 中国电信:China Telecom
     21         * 133,1349,153,180,189
     22         */
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号:010,020,021,022,023,024,025,027,028,029
     27         * 号码:七位或八位
     28         */
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES)) {
        return YES;
    } else {
        return NO;
    }
}

+ (void)setApplicationIconBadgeNumber:(NSInteger)badgeNumber {
    if (badgeNumber < 0) {
        badgeNumber = 0;
    }
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeNumber];
}

+ (void)sendNotificationOnMainThread:(NSString *)notificationName withObject:(id)object {
    NSNotification *notification = [NSNotification notificationWithName:notificationName object:object userInfo:nil];
    if ([NSThread isMainThread] == YES) {
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    } else {
        [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:NO];
    }
}

+ (void)sendNotification:(NSString *)notificationName withObject:(id)object {
    NSNotification *notification = [NSNotification notificationWithName:notificationName object:object userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

+ (CGSize)labelSize:(NSString *)text font:(UIFont *)font {
    return ([self isStringEmpty:text] == NO ? [text sizeWithFont:font] : CGSizeZero);
}

+ (CGSize)labelSize:(NSString *)text font:(UIFont *)font maximumSize:(CGSize)maximumSize {
    CGSize labelSize;
    if ([self isStringEmpty:text] == YES) {
        labelSize = CGSizeZero;
    } else {
        if ([XIOSVersion systemVersion] >= 7.0) {
            NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName,nil];
            labelSize = [text boundingRectWithSize:maximumSize options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
        } else {
            labelSize = [text sizeWithFont:font constrainedToSize:maximumSize lineBreakMode:NSLineBreakByWordWrapping];
        }
    }
    return labelSize;
}

+ (CGFloat)heightForText:(NSString *)text font:(UIFont *)font width:(CGFloat)width {
    CGSize maximumLabelSize = CGSizeMake(width, MAXFLOAT);
    CGSize labelSize = [self labelSize:text font:font maximumSize:maximumLabelSize];
    
    return labelSize.height + 1;
}

+ (CGFloat)heightForText:(NSString *)text font:(UIFont *)font width:(CGFloat)width maxHeight:(CGFloat)maxHeight {
    CGSize maximumLabelSize = CGSizeMake(width, maxHeight);
    CGSize labelSize = [self labelSize:text font:font maximumSize:maximumLabelSize];
    return labelSize.height + 1;
}

+ (CGFloat)widthForText:(NSString *)text font:(UIFont *)font height:(CGFloat)height {
    CGSize maximumLabelSize = CGSizeMake(MAXFLOAT, height);
    CGSize labelSize = [self labelSize:text font:font maximumSize:maximumLabelSize];
    return labelSize.width;
}

+ (CGFloat)widthForText:(NSString *)text font:(UIFont *)font height:(CGFloat)height maxWidth:(CGFloat)maxWidth {
    CGSize maximumLabelSize = CGSizeMake(maxWidth, height);
    CGSize labelSize = [self labelSize:text font:font maximumSize:maximumLabelSize];
    return labelSize.width;
}

+ (NSString *)charToString:(char *)c {
    if (c) {
        return [[NSString alloc] initWithUTF8String:c];
    } else {
        return @"";
    }
}

+ (void)preventShelteredFromNavigationBarForViewController:(UIViewController *)viewController {
    if( ([XIOSVersion systemVersion] >= 7.0)) {
        [viewController setEdgesForExtendedLayout:UIRectEdgeLeft | UIRectEdgeRight | UIRectEdgeBottom];
        [viewController setExtendedLayoutIncludesOpaqueBars:NO];
        [viewController setModalPresentationCapturesStatusBarAppearance:NO];
    }
}

+ (BOOL)appNotFirstLaunch {
    NSString *key = @"appNotFirstLaunch";
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL appNotFirstLaunch = [userDefaults boolForKey:key];
    if (appNotFirstLaunch == NO) {
        [userDefaults setBool:YES forKey:key];
    }
    return appNotFirstLaunch;
}

+ (NSString *)getAppName {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    return appName;
}

+ (const CGFloat *)getRGBFromColor:(UIColor *)color {
    if (color == nil) {
        return nil;
    }
    
    CGColorRef colorRef = [color CGColor];
    size_t numComponents = CGColorGetNumberOfComponents(colorRef);
    
    if (numComponents == 4) {
        const CGFloat *components = CGColorGetComponents(colorRef);
        return components;
    } else {
        return nil;
    }
}

+ (CGFloat)getAlphaFromColor:(UIColor *)color {
    if (color == nil) {
        return -1;
    }
    
    CGColorRef colorRef = [color CGColor];
    
    CGFloat alpha = CGColorGetAlpha(colorRef);
    
    return alpha;
}

+ (CGAffineTransform)rotationWithAngle:(CGFloat)angle {
    return CGAffineTransformMakeRotation(angle);
}

+ (NSString *)base64EncodedStringWithData:(NSData *)data {
    if (data == nil) {
        return @"";
    }
    if ([XIOSVersion isIOS7OrGreater] == YES) {
        return [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    } else {
        return [data base64EncodedString];
    }
}

+ (NSData *)base64DecodedDataWithString:(NSString *)base64String {
    if ([self isStringEmpty:base64String] == YES) {
        return nil;
    }
    if ([XIOSVersion isIOS7OrGreater] == YES) {
        return [[NSData alloc] initWithBase64EncodedString:base64String options:0];
    } else {
        return [base64String base64DecodedData];
    }
}

@end
