//
//  XCookieManager.m
//  XFramework
//
//  Created by XJY on 15-7-26.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import "XCookieManager.h"
#import "XTool.h"

@implementation XCookieManager

+ (NSArray *)getAllCookies {
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    return cookieStorage.cookies;
}

+ (NSHTTPCookie *)getCookieWithKeywordInName:(NSString *)keyword {
    NSArray *allCookies = [self getAllCookies];
    for (NSHTTPCookie *cookie in allCookies) {
        if (cookie != nil &&
            [XTool isStringEmpty:cookie.name] == NO &&
            [XTool isStringEmpty:cookie.value] == NO &&
            [cookie.name rangeOfString:keyword].location != NSNotFound) {
            return cookie;
        }
    }
    return nil;
}

+ (void)addCookie:(NSHTTPCookie *)cookie {
    if (cookie != nil) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    }
}

+ (void)removeCookieWithKeywordInName:(NSString *)keyword {
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *allCookies = cookieStorage.cookies;
    for (NSHTTPCookie *cookie in allCookies) {
        if (cookie != nil &&
            [XTool isStringEmpty:cookie.name] == NO &&
            [XTool isStringEmpty:cookie.value] == NO &&
            [cookie.name rangeOfString:keyword].location != NSNotFound) {
            [cookieStorage deleteCookie:cookie];
        }
    }
}

+ (void)removeCookie:(NSHTTPCookie *)cookie {
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    if (cookie != nil) {
        [cookieStorage deleteCookie:cookie];
    }
}

+ (void)clearCookies {
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *allCookies = cookieStorage.cookies;
    for (NSHTTPCookie *cookie in allCookies) {
        [cookieStorage deleteCookie:cookie];
    }
}

@end
