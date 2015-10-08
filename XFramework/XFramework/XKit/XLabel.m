//
//  XLabel.m
//  XFramework
//
//  Created by XJY on 15-7-26.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import "XLabel.h"
#import "XTool.h"
#import "XIOSVersion.h"

@implementation UILabel (XLabel)

- (CGSize)labelSize {
    return ([XTool isStringEmpty:self.text] == NO ? [self.text sizeWithFont:self.font] : CGSizeZero);
}

- (CGSize)labelSize:(CGSize)maximumLabelSize {
    CGSize labelSize;
    if ([XTool isStringEmpty:self.text] == YES) {
        labelSize = CGSizeZero;
    } else {
        if ([XIOSVersion systemVersion] >= 7.0) {
            NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:self.font, NSFontAttributeName,nil];
            labelSize = [self.text boundingRectWithSize:maximumLabelSize options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
        } else {
            labelSize = [self.text sizeWithFont:self.font constrainedToSize:maximumLabelSize lineBreakMode:NSLineBreakByWordWrapping];
        }
    }
    return labelSize;
}

- (CGFloat)widthForHeight:(CGFloat)height {
    CGSize maximumLabelSize = CGSizeMake(MAXFLOAT, height);
    CGSize labelSize = [self labelSize:maximumLabelSize];
    return labelSize.width;
}

- (CGFloat)widthForHeight:(CGFloat)height maxWidth:(CGFloat)maxWidth {
    CGSize maximumLabelSize = CGSizeMake(maxWidth, height);
    CGSize labelSize = [self labelSize:maximumLabelSize];
    return labelSize.width;
}

- (CGFloat)heightForWidth:(CGFloat)width {
    CGSize maximumLabelSize = CGSizeMake(width, MAXFLOAT);
    CGSize labelSize = [self labelSize:maximumLabelSize];
    return labelSize.height + 1;
}

- (CGFloat)heightForWidth:(CGFloat)width maxHeight:(CGFloat)maxHeight {
    CGSize maximumLabelSize = CGSizeMake(width, maxHeight);
    CGSize labelSize = [self labelSize:maximumLabelSize];
    return labelSize.height + 1;
}

- (void)allowMultiLine {
    [self setNumberOfLines:0];
    [self setLineBreakMode:NSLineBreakByWordWrapping|NSLineBreakByTruncatingTail];
}

@end
