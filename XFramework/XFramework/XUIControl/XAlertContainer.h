//
//  XAlertContainer.h
//  XFramework
//
//  Created by XJY on 15/8/25.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, XAlertContainerBackgroundStyle) {
    XAlertContainerBackgroundStyleGradient = 0,
    XAlertContainerBackgroundStyleSolid,
};

@class XAlertContainerController;

@interface XAlertContainer : NSObject

@property (nonatomic, assign) XAlertContainerBackgroundStyle style;
@property (nonatomic, strong) UIColor   *containerBackgroundColor;

@property (nonatomic, assign) BOOL enableAutoHide;
@property (nonatomic, assign) BOOL enableTapGestureHide;

@property (nonatomic, assign) uint64_t timeout;

@property (nonatomic, strong, readonly) UIView *containerView;

- (instancetype)initWithCustomView:(UIView *)view;

- (void)show;

- (void)hide;

@end
