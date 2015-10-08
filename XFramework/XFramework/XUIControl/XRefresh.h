//
//  XRefresh.h
//  XFramework
//
//  Created by XJY on 15-7-28.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (XRefresh)

typedef NS_OPTIONS(NSUInteger, XRefreshingType) {
    XRefreshingTypeHeader = 1 << 0,
    XRefreshingTypeFooter = 1 << 1
};

/**
 是否允许上拉刷新和下拉刷新同时执行.
 当用MJRefresh自带的添加刷新方法时,必须调用- (BOOL)isAllowRefresh:(RefreshingType)refreshingType;当用自己封装的方法时,无需调用.
 */
@property (nonatomic, assign) BOOL allowHeaderAndFooterRefreshingAtTheSameTime;

/**
 添加下拉刷新
 */
- (void)headerWithRefreshingTarget:(id)target refreshingAction:(SEL)action;

- (void)headerWithRefreshingBlock:(void (^)())block;

/**
 添加上拉加载
 */
- (void)footerWithRefreshingTarget:(id)target refreshingAction:(SEL)action;

- (void)footerWithRefreshingBlock:(void (^)())block;

- (void)footerBackWithRefreshingTarget:(id)target refreshingAction:(SEL)action;

- (void)footerBackWithRefreshingBlock:(void (^)())block;

/**
 开始指定刷新
 */
- (void)beginRefresh:(XRefreshingType)refreshingType;

/**
 停止指定刷新
 */
- (void)endRefresh:(XRefreshingType)refreshingType;

/**
 停止所有刷新
 */
- (void)endAllRefresh;

/**
 设置上下拉刷新的文字
 */
- (void)setRefreshTitleForStateIdle:(NSString *)title forRefresh:(XRefreshingType)refreshingType;

- (void)setRefreshTitleForStatePulling:(NSString *)title forRefresh:(XRefreshingType)refreshingType;

- (void)setRefreshTitleForStateRefreshing:(NSString *)title forRefresh:(XRefreshingType)refreshingType;

- (void)setRefreshTitleForStateWillRefresh:(NSString *)title forRefresh:(XRefreshingType)refreshingType;

- (void)setFooterRefreshTitleForStateNoMoreData:(NSString *)title;

/**
 判断是否允许刷新
 */
- (BOOL)isAllowRefresh:(XRefreshingType)refreshingType;

/**
 判断是否正在刷新
 */
- (BOOL)isRefreshing:(XRefreshingType)refreshingType;

/**
 复位刷新状态
 */
- (void)resetRefreshState:(XRefreshingType)refreshingType;

/**
 复位所有刷新状态
 */
- (void)resetAllRefreshState;

/**
 设置上拉加载是否自动执行;当为NO时,滚动到底部不会立即执行,需要上拉一段距离.
 */
- (void)setFooterRefreshAutomaticallyRefresh:(BOOL)automaticallyRefresh;

/**
 设置是否自动改变透明度
 */
- (void)setRefreshAutoChangeAlpha:(BOOL)autoChangeAlpha forRefresh:(XRefreshingType)refreshingType;

/**
 设置刷新是否隐藏
 */
- (void)setRefreshHidden:(XRefreshingType)refreshingType hidden:(BOOL)hidden;

/**
 上拉加载设置为无更多数据时的状态
 */
- (void)noticeNoMoreData;

/**
 判断上拉加载是否为无更多数据时的状态
 */
- (BOOL)isNoMoreData;

@end
