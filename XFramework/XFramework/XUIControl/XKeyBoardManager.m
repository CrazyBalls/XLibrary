//
//  XKeyBoardManager.m
//  XFramework
//
//  Created by XJY on 15-7-29.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import "XKeyBoardManager.h"

@implementation XKeyBoardManager

+ (void)openIQKeyboardManager {
    IQKeyboardManager *keyboardManager = [IQKeyboardManager sharedManager];
    [keyboardManager setEnable:YES];
    [keyboardManager setShouldResignOnTouchOutside:YES];
    [keyboardManager setKeyboardDistanceFromTextField:0];
}

+ (void)closeIQKeyboardManager {
    IQKeyboardManager *keyboardManager = [IQKeyboardManager sharedManager];
    [keyboardManager setEnable:NO];
    [keyboardManager setShouldResignOnTouchOutside:NO];
    [keyboardManager setKeyboardDistanceFromTextField:0];
}

+ (void)setToolbarTitle:(UITextField *)textField title:(NSString *)title {
    IQToolbar *toolbar = [self getToolbar:textField];
    if (toolbar != nil) {
        [textField setPlaceholder:title];
        [toolbar setTitle:title];
    }
}

+ (NSString *)getToolbarTitle:(UITextField *)textField {
    NSString *title = @"";
    IQToolbar *toolbar = [self getToolbar:textField];
    if (toolbar != nil) {
        title = toolbar.title;
    }
    return title;
}

+ (IQToolbar *)getToolbar:(UITextField *)textField {
    IQToolbar *toolbar = nil;
    if ([textField.inputAccessoryView isKindOfClass:[IQToolbar class]] &&
        (textField.inputAccessoryView.tag == kIQDoneButtonToolbarTag ||
         textField.inputAccessoryView.tag == kIQPreviousNextButtonToolbarTag)) {
            toolbar = (IQToolbar*)[textField inputAccessoryView];
        }
    return toolbar;
}

@end
