//
//  TestCell.m
//  XExample
//
//  Created by XJY on 15/9/28.
//  Copyright © 2015年 XJY. All rights reserved.
//

#import "TestCell.h"
#import "TestModel.h"

@implementation TestCell {
//    UILabel *label;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initialize];
        [self addContentCell];
    }
    return self;
}

- (void)initialize {
    if ([XIOSVersion systemVersion] >= 7.0 && [XIOSVersion systemVersion] < 8.0) {
        for (UIView *view in self.subviews){
            if ([NSStringFromClass([view class]) isEqualToString:@"UITableViewCellScrollView"]) {
                UIScrollView *sv = (UIScrollView *)view;
                [sv setDelaysContentTouches:NO];
                break;
            }
        }
    }
    [self setBackgroundColor:[UIColor clearColor]];
    [self.contentView setBackgroundColor:[UIColor clearColor]];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void)addContentCell {
//    label = [[UILabel alloc] init];
//    [label setBackgroundColor:[UIColor clearColor]];
//    [label setTextColor:[UIColor blackColor]];
//    [self.contentView addSubview:label];
}

- (void)layoutSubviews {
    [super layoutSubviews];
//    [label setFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
}

- (void)addModel:(id)model {
    [super addModel:model];
    TestModel *testModel = (TestModel *)model;
    [self.textLabel setText:testModel.text];
    [self.contentView setBackgroundColor:testModel.bgColor];
}

@end
