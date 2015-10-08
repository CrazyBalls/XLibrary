//
//  XGroupTableCell.m
//  XFrameworkExample
//
//  Created by XJY on 15-8-10.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import "XGroupTableCell.h"

@implementation XGroupTableCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)getCellHeight:(id)model width:(CGFloat)width {
    return 50;
}

- (void)addModel:(id)model {
    _currentGroupTableModel = model;
}

@end
