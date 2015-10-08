//
//  XTextView.m
//  XFramework
//
//  Created by XJY on 15-7-26.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import "XTextView.h"

@implementation XTextView {
    UILabel *placeHolderLabel;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _maxLengthForInput = 0;
        _placeholder = @"";
        _placeholderColor = [UIColor lightGrayColor];
    }
    return self;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (self.secureTextEntry == YES) {
        return NO;
    } else {
        if (action == @selector(cut:) ||
            action == @selector(copy:) ||
            action == @selector(paste:) ||
            action == @selector(select:) ||
            action == @selector(selectAll:)) {
            return YES;
        } else {
            return NO;
        }
    }
}

- (void)delete:(id)sender {
    //实现长按选择删除方法,如果不实现这方法,点击删除按钮会崩溃!
}

- (void)checkTextLimited {
    bool isChinese;//判断当前输入法是否是中文
    if ([[[UITextInputMode currentInputMode] primaryLanguage] isEqualToString: @"en-US"] == YES) {
        isChinese = NO;
    } else {
        isChinese = YES;
    }
    NSString *text = [self.text stringByReplacingOccurrencesOfString:@"?" withString:@""];
    if (isChinese == YES) {//中文输入法下
        UITextRange *selectedRange = [self markedTextRange];
        //获取高亮部分
        UITextPosition *position = [self positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字,则对已输入的文字进行字数统计和限制
        if (position == nil) {
            [self updateText:text];
        }
    } else {
        [self updateText:text];
    }
}

- (void)updateText:(NSString *)text {
    if (_maxLengthForInput != 0) {
        if (text.length > _maxLengthForInput) {
            NSString *newText = [NSString stringWithString:text];
            [self setText:[newText substringToIndex:_maxLengthForInput]];
        }
    }
    if(_x_Delegate != nil && [_x_Delegate respondsToSelector:@selector(updateInputLengthForTextView:)]) {
        [_x_Delegate updateInputLengthForTextView:self];
    }
}

- (void)refreshPlaceholder {
    [placeHolderLabel setAlpha:self.text.length > 0 ? 0 : 1];
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self refreshPlaceholder];
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    [placeHolderLabel setFont:self.font];
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    
    if (placeHolderLabel == nil) {
        placeHolderLabel = [[UILabel alloc] init];
        [placeHolderLabel setBackgroundColor:[UIColor clearColor]];
        [placeHolderLabel setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
        [placeHolderLabel setTextAlignment:self.textAlignment];
        [placeHolderLabel setNumberOfLines:0];
        [placeHolderLabel setLineBreakMode:NSLineBreakByWordWrapping|NSLineBreakByTruncatingTail];
        [placeHolderLabel setFont:self.font];
        [placeHolderLabel setTextColor:_placeholderColor];
        [placeHolderLabel setAlpha:0];
        [self addSubview:placeHolderLabel];
    }
    [placeHolderLabel setText:_placeholder];
    [self updatePlaceHolderLabelFrame];
    [self refreshPlaceholder];
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor {
    _placeholderColor = placeholderColor;
    [placeHolderLabel setTextColor:_placeholderColor];
}

- (void)updatePlaceHolderLabelFrame {
    if(placeHolderLabel != nil) {
        [placeHolderLabel setTextAlignment:self.textAlignment];
        CGFloat offset = 8;
        [placeHolderLabel setFrame:CGRectMake(offset, 0, self.frame.size.width - offset * 2, self.frame.size.height)];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updatePlaceHolderLabelFrame];
}

//When any text changes on textField, the delegate getter is called. At this time we refresh the textView's placeholder
- (id<UITextViewDelegate>)delegate {
    [self refreshPlaceholder];
    return [super delegate];
}

@end
