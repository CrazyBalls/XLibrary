//
//  XControl.m
//  XFramework
//
//  Created by XJY on 15-8-15.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import "XControl.h"

@implementation UIControl (XControl)

- (void)addTarget:(id)target normalAction:(SEL)normalAction hoverAction:(SEL)hoverAction clickAction:(SEL)clickAction {
    [self addTarget:target action:normalAction forControlEvents:UIControlEventTouchCancel | UIControlEventTouchDragExit | UIControlEventTouchDragOutside | UIControlEventTouchUpOutside];
    [self addTarget:target action:hoverAction forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragEnter | UIControlEventTouchDragInside];
    [self addTarget:target action:clickAction forControlEvents:UIControlEventTouchUpInside];
}

@end
