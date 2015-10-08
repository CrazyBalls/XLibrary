//
//  XControl.h
//  XFramework
//
//  Created by XJY on 15-8-15.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIControl (XControl)

- (void)addTarget:(id)target normalAction:(SEL)normalAction hoverAction:(SEL)hoverAction clickAction:(SEL)clickAction;

@end
