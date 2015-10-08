//
//  XAnimation.h
//  XFramework
//
//  Created by XJY on 15-8-7.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XAnimation : NSObject

#define kRadianToDegrees(radian) (radian*M_PI)/180.0

+ (void)animationEaseInEaseOut:(UIView *)outView duration:(CFTimeInterval)duration;

+ (void)beginAnimation:(double)duration executingBlock:(void(^)())block;

- (CABasicAnimation *)rotation:(double)duration degree:(CGFloat)degree direction:(CGFloat)direction repeatCount:(float)repeatCount target:(id)target;

@end
