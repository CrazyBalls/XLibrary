//
//  XBottomBar.m
//  XBottomBar
//
//  Created by XJY on 15-3-4.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import "XBottomBar.h"
#import "XLabel.h"
#import "XScrollView.h"
#import "XFoundation.h"
#import "XTool.h"

@interface XBottomBar () <UIScrollViewDelegate> {
    XScrollView *bottomBarScrollView;
    UIView *separator;
    UIView *selectedView;
    UIView *leftArrowView;
    UIView *rightArrowView;
    UIImageView *leftArrowImageView;
    UIImageView *rightArrowImageView;
    
    NSMutableDictionary *itemDic;
}

@end

@implementation XBottomBar

@synthesize maxItemsCountForRow;
@synthesize defaultSelectedItemIndex;
@synthesize itemFont;
@synthesize itemNormalColor;
@synthesize itemSelectedColor;
@synthesize itemDisableColor;
@synthesize notChangeStateItemIndex;

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initialize];
        [self addSeparator];
        [self addScrollView];
        [self addArrow];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
        [self addSeparator];
        [self addScrollView];
        [self addArrow];
        [self updateFrame];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self updateFrame];
}

#pragma mark private Method

- (void)initialize {
    [self setBackgroundColor:[UIColor whiteColor]];
    [self setAlpha:1.0f];
    itemDic = [[NSMutableDictionary alloc] init];
    maxItemsCountForRow = 5;
    defaultSelectedItemIndex = 0;
    _leftArrowImage = nil;
    _rightArrowImage = nil;
    itemFont = [UIFont fontWithName:@"Helvetica" size:13];
    itemNormalColor = [UIColor blackColor];
    itemSelectedColor = [UIColor blueColor];
    itemDisableColor = [UIColor lightGrayColor];
    notChangeStateItemIndex = -1;
}

- (void)addSeparator {
    separator = [[UIView alloc] init];
    [separator setBackgroundColor:[UIColor colorWithRed:221.0/255 green:221.0/255 blue:221.0/255 alpha:1]];
    [self addSubview:separator];
}

- (void)addScrollView {
    bottomBarScrollView = [[XScrollView alloc] init];
    [bottomBarScrollView setBackgroundColor:[UIColor clearColor]];
    [bottomBarScrollView setPagingEnabled:NO];
    [bottomBarScrollView setBounces:YES];
    [bottomBarScrollView setDelegate:self];
    [bottomBarScrollView setShowsHorizontalScrollIndicator:NO];
    [bottomBarScrollView setShowsVerticalScrollIndicator:NO];
    [bottomBarScrollView setDelaysContentTouches:NO];
    [self addSubview:bottomBarScrollView];
}

- (void)addArrow {
    leftArrowView = [[UIView alloc] init];
    [leftArrowView setBackgroundColor:[UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1]];
    [leftArrowView setHidden:YES];
    [self addSubview:leftArrowView];
    
    leftArrowImageView = [[UIImageView alloc] init];
    [leftArrowImageView setImage:_leftArrowImage];
    [leftArrowImageView setHidden:YES];
    [leftArrowView addSubview:leftArrowImageView];
    
    rightArrowView = [[UIView alloc] init];
    [rightArrowView setBackgroundColor:[UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1]];
    [rightArrowView setHidden:YES];
    [self addSubview:rightArrowView];
    
    rightArrowImageView = [[UIImageView alloc] init];
    [rightArrowImageView setImage:_rightArrowImage];
    [rightArrowImageView setHidden:YES];
    [rightArrowView addSubview:rightArrowImageView];
}

- (void)updateFrame {
    CGFloat separatorHeight = 0.5;
    [separator setFrame:CGRectMake(0, 0, self.frame.size.width, separatorHeight)];
    [bottomBarScrollView setFrame:CGRectMake(0, separatorHeight, self.frame.size.width, self.frame.size.height - separatorHeight)];
    
    CGFloat arrowViewWidth = 0;
    CGFloat arrowViewHeight = 0;
    CGFloat leftArrowViewX = 0;
    CGFloat arrowViewY = 0;
    CGFloat leftArrowImageViewHeight = 0;
    CGFloat leftArrowImageViewY = 0;

    if (leftArrowImageView.image != nil) {
        arrowViewWidth = 7;
        arrowViewHeight = self.frame.size.height - separatorHeight;
        leftArrowViewX = 0;
        arrowViewY = separatorHeight;
        CGFloat leftArrowImageScale = leftArrowImageView.image.size.width * 1.0 / leftArrowImageView.image.size.height;
        leftArrowImageViewHeight = arrowViewWidth * 1.0 / leftArrowImageScale;
        leftArrowImageViewY = (arrowViewHeight - leftArrowImageViewHeight) / 2.0;
    }
    [leftArrowView setFrame:CGRectMake(leftArrowViewX, arrowViewY, arrowViewWidth, arrowViewHeight)];
    [leftArrowImageView setFrame:CGRectMake(0, leftArrowImageViewY, arrowViewWidth, leftArrowImageViewHeight)];
    

    CGFloat rightArrowViewX = 0;
    CGFloat rightArrowImageViewHeight = 0;
    CGFloat rightArrowImageViewY = 0;
    
    if (rightArrowImageView.image != nil) {
        arrowViewWidth = 7;
        arrowViewHeight = self.frame.size.height - separatorHeight;
        rightArrowViewX = self.frame.size.width - arrowViewWidth;
        arrowViewY = separatorHeight;
        CGFloat rightArrowImageScale = rightArrowImageView.image.size.width * 1.0 / rightArrowImageView.image.size.height;
        rightArrowImageViewHeight = arrowViewWidth * 1.0 / rightArrowImageScale;
        rightArrowImageViewY = (arrowViewHeight - rightArrowImageViewHeight) / 2.0;
    }
    
    rightArrowView = [[UIView alloc] initWithFrame:CGRectMake(rightArrowViewX, arrowViewY, arrowViewWidth, arrowViewHeight)];
    [rightArrowImageView setFrame:CGRectMake(0, rightArrowImageViewY, arrowViewWidth, rightArrowImageViewHeight)];
}

#pragma mark public Method

- (void)addItems:(NSArray *)itemsArr {
    [itemDic removeAllObjects];
    for (XBottomBarModel *bottomBarModel in itemsArr) {
        NSInteger itemTag = bottomBarModel.tag;
        [itemDic x_setObject:bottomBarModel forKey:[NSNumber numberWithInteger:itemTag]];
    }
    
    //移除scrollview中当前所有的子控件,否则会叠加
    for (UIView *view in bottomBarScrollView.subviews) {
        [view removeFromSuperview];
    }
    
    CGFloat itemViewWidth = 0;
    CGFloat itemViewHeight = bottomBarScrollView.frame.size.height;
    CGFloat itemViewX = 0;
    CGFloat itemViewY = 0;

    if (itemDic.count <= maxItemsCountForRow) {
        itemViewWidth = bottomBarScrollView.frame.size.width * 1.0 / itemDic.count;
    }else{
        itemViewWidth = bottomBarScrollView.frame.size.width * 1.0 / maxItemsCountForRow;
        [rightArrowView setHidden:NO];
        [rightArrowImageView setHidden:NO];
    }

    [bottomBarScrollView setContentSize:CGSizeMake(itemViewWidth * itemDic.count, bottomBarScrollView.frame.size.height)];

    for (int i = 0; i < itemDic.count; i++) {
        NSInteger tag = i + 1;
        XBottomBarModel *bottomBarModel = [itemDic objectForKey:[NSNumber numberWithInteger:i]];
        NSString *itemTitle = bottomBarModel.text;

        UIView *itemView = [[UIView alloc] init];
        [itemView setUserInteractionEnabled:YES];
        [itemView setBackgroundColor:[UIColor clearColor]];
        [itemView setTag:tag];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemClickEvent:)];
        [itemView addGestureRecognizer:tapGesture];
        [bottomBarScrollView addSubview:itemView];
        
        UIImageView *itemImageView = [[UIImageView alloc] init];
        [itemImageView setBackgroundColor:[UIColor clearColor]];
        [itemImageView setImage:bottomBarModel.normalImage];
        [itemImageView setTag:(tag+itemDic.count)];
        [itemView addSubview:itemImageView];
        
        UILabel *itemLabel = [[UILabel alloc] init];
        [itemLabel setBackgroundColor:[UIColor clearColor]];
        [itemLabel setText:itemTitle];
        [itemLabel setFont:itemFont];
        [itemLabel setTextColor:itemNormalColor];
        [itemLabel setTextAlignment:NSTextAlignmentCenter];
        [itemLabel setTag:(tag+itemDic.count*2)];
        [itemView addSubview:itemLabel];
        
        UILabel *badge = [[UILabel alloc] init];
        [badge setBackgroundColor:[UIColor clearColor]];
        [badge setText:@""];
        [badge setTextAlignment:NSTextAlignmentCenter];
        [badge setTextColor:[UIColor whiteColor]];
        [badge setFont:[UIFont fontWithName:@"Helvetica-Bold" size:8]];
        [badge setHidden:YES];
        [badge setTag:(tag+itemDic.count*3)];
        [badge.layer setMasksToBounds:YES];
        [badge.layer setBackgroundColor:[UIColor redColor].CGColor];
        [itemView addSubview:badge];
        
        itemViewX = itemViewWidth * i;

        CGFloat itemImageViewWidth = 0;
        CGFloat itemImageViewHeight = 0;
        CGFloat itemImageViewX = 0;
        CGFloat itemImageViewY = 0;
        
        if (itemImageView.image != nil) {
            itemImageViewWidth = itemImageView.image.size.width / 2.0;
            itemImageViewHeight = itemImageView.image.size.height / 2.0;
            itemImageViewX = (itemViewWidth - itemImageViewWidth) / 2.0;
        }
        
        CGSize itemLabelSize = [itemLabel labelSize];
        CGFloat itemLabelWidth = itemLabelSize.width;
        CGFloat itemLabelHeight = itemLabelSize.height;
        CGFloat itemLabelX = (itemViewWidth - itemLabelWidth) / 2.0;
        CGFloat itemLabelY = 0;
        
        itemImageViewY = (itemViewHeight - itemImageViewHeight - itemLabelHeight) / 2.0;
        itemLabelY = itemImageViewY + itemImageViewHeight;

        [itemView setFrame:CGRectMake(itemViewX, itemViewY, itemViewWidth, itemViewHeight)];
        [itemImageView setFrame:CGRectMake(itemImageViewX, itemImageViewY, itemImageViewWidth, itemImageViewHeight)];
        [itemLabel setFrame:CGRectMake(itemLabelX, itemLabelY, itemLabelWidth, itemLabelHeight)];
    }
    [self setItemState:[bottomBarScrollView viewWithTag:defaultSelectedItemIndex+1] isSelected:YES];
}

- (NSString *)getItemTitle:(NSInteger)index {
    XBottomBarModel *bottomBarModel = [itemDic objectForKey:[NSNumber numberWithInteger:index]];
    NSString *itemTitle = bottomBarModel.text;
    return itemTitle;
}

- (void)setItemEnableAtIndex:(NSInteger)index enable:(BOOL)enable {
    XBottomBarModel *bottomBarModel = [itemDic objectForKey:[NSNumber numberWithInteger:index]];
    UIView *itemView = [bottomBarScrollView viewWithTag:index+1];
    UIImageView *itemImageView = (UIImageView *)[itemView viewWithTag:(itemView.tag + itemDic.count)];
    UILabel *itemLabel = (UILabel *)[itemView viewWithTag:(itemView.tag + itemDic.count*2)];
    [itemView setUserInteractionEnabled:enable];
    
    if (enable == YES) {
        if (selectedView != nil && selectedView.tag == index+1) {
            if (itemImageView.image != bottomBarModel.selectedImage) {
                [itemImageView setImage:bottomBarModel.selectedImage];
            }
            if (itemLabel.textColor != itemSelectedColor) {
                [itemLabel setTextColor:itemSelectedColor];
            }
        } else {
            if (itemImageView.image != bottomBarModel.normalImage) {
                [itemImageView setImage:bottomBarModel.normalImage];
            }
            if (itemLabel.textColor != itemNormalColor) {
                [itemLabel setTextColor:itemNormalColor];
            }
        }
    } else {
        if (itemImageView.image != bottomBarModel.disableImage) {
            [itemImageView setImage:bottomBarModel.disableImage];
        }
        if (itemLabel.textColor != itemDisableColor) {
            [itemLabel setTextColor:itemDisableColor];
        }
    }
}

- (void)setLeftArrowHidden:(BOOL)leftHidden RightArrowHidden:(BOOL)rightHidden {
    [leftArrowView setHidden:leftHidden];
    [leftArrowImageView setHidden:leftHidden];
    [rightArrowView setHidden:rightHidden];
    [rightArrowImageView setHidden:rightHidden];
}

- (void)setScrollTargetFrame:(UIScrollView *)scrollView {
    CGRect frame = scrollView.frame;
    CGFloat scrollViewWidth = scrollView.frame.size.width;
    CGFloat scrollViewContentSizeWidth = scrollView.contentSize.width;
    CGFloat contentXOffset = scrollView.contentOffset.x;
    if (contentXOffset > 0 && contentXOffset < (scrollViewContentSizeWidth - scrollViewWidth)) {
        CGFloat minItemViewWidth = 0;
        if (itemDic.count <= maxItemsCountForRow) {
            minItemViewWidth = bottomBarScrollView.frame.size.width * 1.0 / itemDic.count;
        }else{
            minItemViewWidth = bottomBarScrollView.frame.size.width * 1.0 / maxItemsCountForRow;
        }
        CGFloat result = contentXOffset / minItemViewWidth;
        NSInteger integer = (NSInteger)result;
        CGFloat decimal = result - integer;
        if (decimal > 0.5) {
            frame.origin.x = (integer + 1)*minItemViewWidth;
        } else{
            frame.origin.x = integer*minItemViewWidth;
        }
        [scrollView scrollRectToVisible:frame animated:YES];
    }
}

- (void)setItemState:(UIView *)view isSelected:(BOOL)isSelected {
    XBottomBarModel *bottomBarModel = [itemDic objectForKey:[NSNumber numberWithInteger:view.tag - 1]];
    UIImageView *itemImageView = (UIImageView *)[view viewWithTag:(view.tag + itemDic.count)];
    UILabel *itemLabel = (UILabel *)[view viewWithTag:(view.tag + itemDic.count*2)];

    UIImage *itemImage = nil;
    UIColor *color;
    if (isSelected == NO) {
        itemImage = bottomBarModel.normalImage;
        color = itemNormalColor;
        selectedView = nil;
    }else {
        itemImage = bottomBarModel.selectedImage;
        color = itemSelectedColor;
        selectedView = view;
    }

    [itemImageView setImage:itemImage];
    [itemLabel setTextColor:color];
}

- (void)setItemBadgeFrame:(UILabel *)badge{
    NSInteger itemViewTag = badge.tag - itemDic.count*3;
    UIView *itemView = [bottomBarScrollView viewWithTag:itemViewTag];
    UIImageView *itemImageView = (UIImageView *)[itemView viewWithTag:(itemViewTag + itemDic.count)];
    CGFloat itemViewWidth = itemView.frame.size.width;
    CGFloat itemImageViewX = itemImageView.frame.origin.x;
    CGFloat itemImageViewY = itemImageView.frame.origin.y;
    CGFloat itemImageViewWidth = itemImageView.frame.size.width;
    CGFloat badgeWidth = 0;
    CGFloat badgeHeight = 0;
    CGFloat badgeX = 0;
    CGFloat badgeY = 0;
    if ([XTool isStringEmpty:badge.text] == YES) {
        badgeWidth = itemViewWidth / 8.0;
    } else {
        badgeWidth = itemViewWidth / 4.0;
    }
    badgeHeight = badgeWidth;
    badgeX = itemImageViewX + itemImageViewWidth;
    badgeY = itemImageViewY - badgeHeight / 2.0;
    if (badgeX > itemViewWidth - badgeWidth) {
        badgeX = itemViewWidth - badgeWidth;
    }
    if (badgeY < 0) {
        badgeY = 0;
    }
    [badge setFrame:CGRectMake(badgeX, badgeY, badgeWidth, badgeHeight)];
    [badge.layer setCornerRadius:badgeWidth / 2.0];
}

- (void)setItemBadgeHiddenAtIndex:(NSInteger)index badgeHidden:(BOOL)hidden {
    NSInteger tag = index+1;
    UIView *itemView = [bottomBarScrollView viewWithTag:tag];
    UILabel *badge = (UILabel *)[itemView viewWithTag:(tag + itemDic.count*3)];
    if (hidden == YES) {
        [badge setText:@""];
    }
    [badge setHidden:hidden];
    [self setItemBadgeFrame:badge];
}

- (void)setItemBadgeHiddenWithTitle:(NSString *)title badgeHidden:(BOOL)hidden {
    for (UIView *itemView in bottomBarScrollView.subviews) {
        NSString *itemTitle = [self getItemTitle:itemView.tag];
        if([itemTitle isEqualToString:title]) {
            [self setItemBadgeHiddenAtIndex:itemView.tag-1 badgeHidden:hidden];
            return;
        }
    }
}

- (void)setItemBadgeTextAtIndex:(NSInteger)index badgeText:(NSString *)text {
    NSInteger tag = index+1;
    UIView *itemView = [bottomBarScrollView viewWithTag:tag];
    UILabel *badge = (UILabel *)[itemView viewWithTag:(tag + itemDic.count*3)];
    [badge setText:text];
    [badge setHidden:NO];
    [self setItemBadgeFrame:badge];
}

- (void)setItemBadgeTextWithTitle:(NSString *)title badgeText:(NSString *)text {
    for (UIView *itemView in bottomBarScrollView.subviews) {
        NSString *itemTitle = [self getItemTitle:itemView.tag];
        if([itemTitle isEqualToString:title]) {
            [self setItemBadgeTextAtIndex:itemView.tag-1 badgeText:text];
            return;
        }
    }
}

- (NSString *)getItemBadgeTextAtIndex:(NSInteger)index {
    NSInteger tag = index+1;
    UIView *itemView = [bottomBarScrollView viewWithTag:tag];
    UILabel *badge = (UILabel *)[itemView viewWithTag:(tag + itemDic.count*3)];
    return badge.text;
}

- (NSString *)getItemBadgeTextWithTitle:(NSString *)title {
    NSString *itemBadgeText = @"";
    for (UIView *itemView in bottomBarScrollView.subviews) {
        NSString *itemTitle = [self getItemTitle:itemView.tag];
        if([itemTitle isEqualToString:title]) {
            itemBadgeText = [self getItemBadgeTextAtIndex:itemView.tag - 1];
            break;
        }
    }
    return itemBadgeText;
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat scrollViewWidth = scrollView.frame.size.width;
    CGFloat scrollViewContentSizeWidth = scrollView.contentSize.width;
    CGFloat contentXOffset = scrollView.contentOffset.x;
    
    if (contentXOffset <= 0) {
        [self setLeftArrowHidden:YES RightArrowHidden:NO];
    }else if (contentXOffset >= (scrollViewContentSizeWidth - scrollViewWidth)) {
        [self setLeftArrowHidden:NO RightArrowHidden:YES];
    }else {
        [self setLeftArrowHidden:NO RightArrowHidden:NO];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self setScrollTargetFrame:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self setScrollTargetFrame:scrollView];
}

#pragma mark itemClickEvent Mothed

- (void)itemClickEvent:(id)sender {
    //将已选中的item恢复到正常状态
    UITapGestureRecognizer *tap = (UITapGestureRecognizer*)sender;
    UIView *itemView = (UIView *)[tap view];
    NSInteger selectedIndex = itemView.tag - 1;
    if (notChangeStateItemIndex != selectedIndex) {
        if (selectedView != nil && itemView == selectedView) {
            //已选择该Item
        } else {
            if (selectedView != nil) {
                [self setItemState:selectedView isSelected:NO];
            }
            [self setItemState:itemView isSelected:YES];
        }
    } else {
        //不要改变状态的Item
    }
    if(_delegate != nil && [_delegate respondsToSelector:@selector(bottomBarItemClick:)]) {
        [_delegate bottomBarItemClick:selectedIndex];
    }
}

@end

@implementation XBottomBarModel
@synthesize normalImage;
@synthesize selectedImage;
@synthesize text;
@synthesize tag;

- (instancetype)init {
    self = [super init];
    if (self) {
        normalImage = nil;
        selectedImage = nil;
        text = @"";
        tag = -1;
    }
    return self;
}

@end
