//
//  XScrollView.m
//  XFramework
//
//  Created by XJY on 15-7-26.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import "XScrollView.h"

@implementation XScrollView

- (BOOL)touchesShouldCancelInContentView:(UIView *)view{
    // 即使触摸到的是一个UIControl(如子类：UIButton), 我们也希望拖动时能取消掉动作以便响应滚动动作
    // cancel click event for dragging
    return YES;
}

@end

