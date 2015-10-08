//
//  XTextField.h
//  XFramework
//
//  Created by XJY on 15-7-26.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XTextFieldDelegate <NSObject>

@optional
- (void)updateInputLengthForTextField:(UITextField *)textField;

@end

@interface XTextField : UITextField

@property (nonatomic, assign)   id <XTextFieldDelegate>     x_Delegate;
@property (nonatomic, assign)   NSInteger                   maxLengthForInput;          //default is 0, unlimited

@property (nonatomic, assign)   BOOL                    multiLinePlaceholderEnable;     //default is NO
@property (nonatomic, copy)     NSString           *    multiLinePlaceholder;           //default is nil;
@property (nonatomic, copy)     NSAttributedString *    multiLineAttributedPlaceholder; //default is nil;
@property (nonatomic)           UIFont             *    multiLinePlaceholderFont;       //default is nil;
@property (nonatomic)           UIColor            *    multiLinePlaceholderColor;      //default is nil;
@property (nonatomic)           NSTextAlignment         multiLinePlaceholderAlignment;  //default is NSLeftTextAlignment;

@end
