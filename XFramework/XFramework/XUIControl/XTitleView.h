//
//  XTitleView.h
//  XTitleView
//
//  Created by XJY on 15-3-4.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XTitleViewDelegate <NSObject>

@optional
- (void)clickTitleViewLeftButton;
- (void)clickTitleViewRightButton;

@end

@interface XTitleView : UIView

@property (nonatomic, assign) id <XTitleViewDelegate> delegate;

@property (nonatomic) UIFont  * leftButtonFont;
@property (nonatomic) UIColor * leftButtonNormalColor;
@property (nonatomic) UIColor * leftButtonHighlightedColor;
@property (nonatomic) UIImage * leftButtonNormalImage;
@property (nonatomic) UIImage * leftButtonHighlightedImage;

@property (nonatomic) UIFont  * rightButtonFont;
@property (nonatomic) UIColor * rightButtonNormalColor;
@property (nonatomic) UIColor * rightButtonHighlightedColor;
@property (nonatomic) UIImage * rightButtonNormalImage;
@property (nonatomic) UIImage * rightButtonHighlightedImage;

@property (nonatomic) UIFont  * titleFont;
@property (nonatomic) UIColor * titleColor;

@property (nonatomic) UIImage * backgroundImage;

/**
 设置按钮显示
 */
- (void)leftButtonHide;
- (void)leftButtonShowAll;
- (void)leftButtonOnlyShowText;
- (void)leftButtonOnlyShowImage;

- (void)rightButtonHide;
- (void)rightButtonShowAll;
- (void)rightButtonOnlyShowText;
- (void)rightButtonOnlyShowImage;

/**
 判断按钮显示
 */
- (BOOL)isLeftButtonHide;
- (BOOL)isLeftButtonShowAll;
- (BOOL)isLeftButtonOnlyShowText;
- (BOOL)isLeftButtonOnlyShowImage;

- (BOOL)isRightButtonHide;
- (BOOL)isRightButtonShowAll;
- (BOOL)isRightButtonOnlyShowText;
- (BOOL)isRightButtonOnlyShowImage;

/**
 设置文字
 */
- (void)setLeftButtonText:(NSString *)text;
- (void)setRightButtonText:(NSString *)text;
- (void)setTitleText:(NSString *)text;

/**
 获取文字
 */
- (NSString *)getLeftButtonText;
- (NSString *)getRightButtonText;
- (NSString *)getTitle;

@end
