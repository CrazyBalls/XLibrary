//
//  XIOSVersion.m
//  XFramework
//
//  Created by XJY on 15-7-26.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import "XIOSVersion.h"
#import <UIKit/UIKit.h>

@implementation XIOSVersion

+ (float)systemVersion {
    return [[UIDevice currentDevice].systemVersion floatValue];
}

+ (double)iosVersion {
    return floor(NSFoundationVersionNumber);
}

+ (BOOL)isIOS6OrGreater {
#ifdef NSFoundationVersionNumber_iOS_5_1
    if ([self iosVersion] > NSFoundationVersionNumber_iOS_5_1) {
        return YES;
    } else {
        return NO;
    }
#else
    return NO;
#endif
}

+ (BOOL)isIOS7OrGreater {
#ifdef NSFoundationVersionNumber_iOS_6_1
    if ([self iosVersion] > NSFoundationVersionNumber_iOS_6_1) {
        return YES;
    } else {
        return NO;
    }
#else
    return NO;
#endif
}

+ (BOOL)isIOS8OrGreater {
#ifdef NSFoundationVersionNumber_iOS_7_1
    if ([self iosVersion] > NSFoundationVersionNumber_iOS_7_1) {
        return YES;
    } else {
        return NO;
    }
#else
    return NO;
#endif
}

+ (BOOL)isIOS9OrGreater {
#ifdef NSFoundationVersionNumber_iOS_8_3
    if ([self iosVersion] > NSFoundationVersionNumber_iOS_8_3) {
        return YES;
    } else {
        return NO;
    }
#else
    return NO;
#endif
}

+ (BOOL)isSDK6OrGreater {
    if (__IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_5_1) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)isSDK7OrGreater {
    if (__IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)isSDK8OrGreater {
    if (__IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)isSDK9OrGreater {
    if (__IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_8_4) {
        return YES;
    } else {
        return NO;
    }
}

@end
