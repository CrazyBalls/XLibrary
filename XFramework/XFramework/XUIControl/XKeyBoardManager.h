//
//  XKeyBoardManager.h
//  XFramework
//
//  Created by XJY on 15-7-29.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UITextField.h>
#import "KeyboardManager.h"

@class IQToolbar;

@interface XKeyBoardManager : NSObject

/**
 打开IQKeyboard
 */
+ (void)openIQKeyboardManager;

/**
 关闭IQKeyboard
 */
+ (void)closeIQKeyboardManager;

/**
 设置键盘上方的toolbar文字,设置时placeholder也会设置,所以记得适当的时候恢复placeholder
 */
+ (void)setToolbarTitle:(UITextField *)textField title:(NSString *)title;

/**
 获取键盘上方的toolbar文字
 */
+ (NSString *)getToolbarTitle:(UITextField *)textField;

/**
 获取键盘上方的toolbar
 */
+ (IQToolbar *)getToolbar:(UITextField *)textField;

@end
