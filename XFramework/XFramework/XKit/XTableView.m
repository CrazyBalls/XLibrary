//
//  XTableView.m
//  XFramework
//
//  Created by XJY on 15-7-26.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import "XTableView.h"
#import "XIOSVersion.h"

@implementation XTableView

- (BOOL)touchesShouldCancelInContentView:(UIView *)view{
    // 即使触摸到的是一个UIControl(如子类：UIButton), 我们也希望拖动时能取消掉动作以便响应滚动动作
    // cancel click event for dragging
    return YES;
}

- (void)setNoDelaysContentTouches {
    [self setDelaysContentTouches:NO];
    if ([XIOSVersion systemVersion] >= 8.0) {
        for (id view in self.subviews) {
            if ([NSStringFromClass([view class]) isEqualToString:@"UITableViewWrapperView"]) {
                [view setDelaysContentTouches:NO];
            }
        }
    }
}

- (void)clearRemainSeparators {
    [self setTableFooterView:[[UIView alloc] init]];
}

- (void)setSeparatorEdgeInsetsZero {
    if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
        [self setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([XIOSVersion isSDK8OrGreater] == YES) {
        if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
            [self setLayoutMargins:UIEdgeInsetsZero];
        }
        if([self respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]){
            [self setPreservesSuperviewLayoutMargins:NO];
        }
    }
}

- (void)setSeparatorOrigin:(UITableViewCell *)cell originX:(CGFloat)originX {
    UIEdgeInsets edgeInsets = (originX == 0 ? UIEdgeInsetsZero : UIEdgeInsetsMake(0, originX, 0, 0));
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:edgeInsets];
    }
    if ([XIOSVersion isSDK8OrGreater] == YES) {
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:edgeInsets];
        }
        if([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]){
            [cell setPreservesSuperviewLayoutMargins:NO];
        }
    }
}

@end

