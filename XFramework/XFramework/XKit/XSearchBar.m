//
//  XSearchBar.m
//  XFramework
//
//  Created by XJY on 15-7-26.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import "XSearchBar.h"
#import "XIOSVersion.h"

@implementation XSearchBar

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    BOOL isSecureTextEntry = YES;
    if ([XIOSVersion isSDK8OrGreater] == YES) {
        isSecureTextEntry = self.secureTextEntry;
    } else {
        isSecureTextEntry = NO;
    }
    if (isSecureTextEntry == YES) {
        return NO;
    } else {
        if (action == @selector(cut:) ||
            action == @selector(copy:) ||
            action == @selector(paste:) ||
            action == @selector(select:) ||
            action == @selector(selectAll:)) {
            return YES;
        } else {
            return NO;
        }
    }
}

- (void)delete:(id)sender {
    //实现长按选择删除方法,如果不实现这方法,点击删除按钮会崩溃！
}

@end
