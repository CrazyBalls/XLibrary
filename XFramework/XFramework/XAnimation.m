//
//  XAnimation.m
//  XFramework
//
//  Created by XJY on 15-8-7.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import "XAnimation.h"
#import <QuartzCore/QuartzCore.h>
#import "XFoundation.h"

@implementation XAnimation

+ (void)animationEaseInEaseOut:(UIView *)outView duration:(CFTimeInterval)duration {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    [animation setDuration:duration];
    [animation setRemovedOnCompletion:NO];
    [animation setFillMode:kCAFillModeForwards];
    NSMutableArray *values = [NSMutableArray array];
    [values x_addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
    [values x_addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
    [values x_addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 0.9)]];
    [values x_addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    [animation setValues:values];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:@"easeInEaseOut"]];
    [outView.layer addAnimation:animation forKey:nil];
}

+ (void)beginAnimation:(double)duration executingBlock:(void(^)())block {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
    block();
    [UIView commitAnimations];
}

- (CABasicAnimation *)rotation:(double)duration degree:(CGFloat)degree direction:(CGFloat)direction repeatCount:(float)repeatCount target:(id)target {
    CATransform3D rotationTransform = CATransform3DMakeRotation(degree, 0, 0, direction);
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.toValue = [NSValue valueWithCATransform3D:rotationTransform];
    animation.duration = duration;
    animation.autoreverses = NO;
    animation.cumulative = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.repeatCount = repeatCount;
    animation.removedOnCompletion = NO;
    animation.delegate = target;
    
    return animation;
}

@end
