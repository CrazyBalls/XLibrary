//
//  XTextView.h
//  XFramework
//
//  Created by XJY on 15-7-26.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XTextViewDelegate <NSObject>

@optional
- (void)updateInputLengthForTextView:(UITextView *)textView;

@end

@interface XTextView : UITextView

@property (nonatomic, assign)   id <XTextViewDelegate> x_Delegate;
@property (nonatomic, copy)     NSString *placeholder;
@property (nonatomic)           UIColor  *placeholderColor;
@property (nonatomic, assign)   NSInteger maxLengthForInput;//default is 0,unlimited

/**
 检测字数是否达到限制,textViewDidChange里调用
 */
- (void)checkTextLimited;

@end
