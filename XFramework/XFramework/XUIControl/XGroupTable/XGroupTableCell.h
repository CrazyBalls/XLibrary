//
//  XGroupTableCell.h
//  XFrameworkExample
//
//  Created by XJY on 15-8-10.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XGroupTableModel.h"

@interface XGroupTableCell : UITableViewCell

#pragma mark property

@property (nonatomic, assign) id delegate;
@property (nonatomic, strong) XGroupTableModel *  currentGroupTableModel;

#pragma mark method

+ (CGFloat)getCellHeight:(id)model width:(CGFloat)width;

- (void)addModel:(id)model;

@end
