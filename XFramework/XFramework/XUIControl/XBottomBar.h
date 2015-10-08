//
//  XBottomBar.h
//  XBottomBar
//
//  Created by XJY on 15-3-4.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XBottomBarDelegate <NSObject>

@optional
- (void)bottomBarItemClick:(NSInteger)index;

@end

@interface XBottomBar : UIView

@property (nonatomic, assign) id <XBottomBarDelegate> delegate;
@property (nonatomic, assign) NSInteger maxItemsCountForRow;//default is 5
@property (nonatomic, assign) NSInteger defaultSelectedItemIndex;//default is 0
@property (nonatomic, assign) NSInteger notChangeStateItemIndex;//default is -1
@property (nonatomic) UIImage *         leftArrowImage;
@property (nonatomic) UIImage *         rightArrowImage;
@property (nonatomic) UIFont  *         itemFont;
@property (nonatomic) UIColor *         itemNormalColor;
@property (nonatomic) UIColor *         itemSelectedColor;
@property (nonatomic) UIColor *         itemDisableColor;

//在调用addItems之前设置以上属性!!!

/**
 添加按钮
 */
- (void)addItems:(NSArray *)itemsArr;

- (NSString *)getItemTitle:(NSInteger)index;

- (void)setItemEnableAtIndex:(NSInteger)index enable:(BOOL)enable;
    
- (void)setItemBadgeHiddenAtIndex:(NSInteger)index badgeHidden:(BOOL)hidden;

- (void)setItemBadgeHiddenWithTitle:(NSString *)title badgeHidden:(BOOL)hidden;

- (void)setItemBadgeTextAtIndex:(NSInteger)index badgeText:(NSString *)text;

- (void)setItemBadgeTextWithTitle:(NSString *)title badgeText:(NSString *)text;

- (NSString *)getItemBadgeTextAtIndex:(NSInteger)index;

- (NSString *)getItemBadgeTextWithTitle:(NSString *)title;

@end

@interface XBottomBarModel : NSObject

@property (nonatomic) UIImage *normalImage;
@property (nonatomic) UIImage *selectedImage;
@property (nonatomic) UIImage *disableImage;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) NSInteger tag;

@end