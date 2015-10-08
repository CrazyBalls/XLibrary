//
//  XTableView.h
//  XFramework
//
//  Created by XJY on 15-7-26.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XTableView : UITableView

/**
 关闭延时,记得自定义cell类里也要关闭延时,但不是调用该方法。
 */
- (void)setNoDelaysContentTouches;

/**
 清除剩余的分割线
 */
- (void)clearRemainSeparators;

/**
 分割线置顶
 */
- (void)setSeparatorEdgeInsetsZero;

/**
 设置分割线与左侧的距离
 */
- (void)setSeparatorOrigin:(UITableViewCell *)cell originX:(CGFloat)originX;

@end
