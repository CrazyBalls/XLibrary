//
//  XTabBar.m
//  XTabBar
//
//  Created by XJY on 15-3-27.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import "XTabBar.h"
#import "XFoundation.h"
#import "XScrollView.h"
#import "XTool.h"
#import "XLabel.h"

@interface XTabBar() <UIScrollViewDelegate> {
    XScrollView     *   tabBarScrollView;
    UIImageView     *   tabLineImageView;
    UIView          *   separator;
    
    NSMutableArray  *   tabsArray;
    
    CGFloat textNormalColorR;
    CGFloat textNormalColorG;
    CGFloat textNormalColorB;

    CGFloat textSelectedColorR;
    CGFloat textSelectedColorG;
    CGFloat textSelectedColorB;
    
    CGFloat textNormalAlpha;
    CGFloat textSelectedAlpha;
}

@end

@implementation XTabBar

#define tabLineImageViewTag (initializeTag - 1)

#define buttonTag(index)    ((index) * 2 + initializeTag)
#define badgeTag(index)     ((buttonTag(index)) + 1)

#define minBadgeSize 7
#define maxBadgeSize minBadgeSize*2

#pragma mark ---------- Public ----------

#pragma mark init

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initialize];
        [self addUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
        [self addUI];
        [self updateFrame];
    }
    return self;
}

- (instancetype)initWithTabs:(NSArray *)tabs {
    self = [self init];
    if (self) {
        [self addTabs:tabs];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame tabs:(NSArray *)tabs {
    self = [self initWithFrame:frame];
    if (self) {
        [self addTabs:tabs];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self setNeedsLayout];
}

#pragma mark tab

- (void)addTabs:(NSArray *)tabs {
    if (tabsArray == nil) {
        tabsArray = [[NSMutableArray alloc] init];
    }
    
    if ([XTool isArrayEmpty:tabs] == NO) {
        for (NSInteger i = 0; i < tabs.count; i ++) {
            NSString *title = [tabs x_objectAtIndex:i];
            [self addTabToScrollView:title atIndex:tabsArray.count + i];
        }
        
        [tabsArray addObjectsFromArray:tabs];
    }
    
    [self updateTabLineImageViewState];
    [self setNeedsLayout];
    [self selectTab:_currentSelectedIndex];
}

- (void)addTab:(NSString *)title {
    if (tabsArray == nil) {
        tabsArray = [[NSMutableArray alloc] init];
    }
    
    [self addTabToScrollView:title atIndex:tabsArray.count];
    [tabsArray x_addObject:title];
    
    [self updateTabLineImageViewState];
    [self setNeedsLayout];
    [self selectTab:_currentSelectedIndex];
}

- (void)removeAllTabs {
    [tabsArray removeAllObjects];
    _currentSelectedIndex = NSNotFound;
    [self removeAllTabsFromScrollView];
    [self updateTabLineImageViewState];
    [self setNeedsLayout];
}

- (void)removeTabAtIndex:(NSInteger)atIndex {
    if (atIndex == NSNotFound || atIndex < 0 || atIndex >= tabsArray.count) {
        return;
    }
    
    if ([XTool isArrayEmpty:tabsArray] == YES) {
        return;
    }
    
    if (_currentSelectedIndex != NSNotFound && _currentSelectedIndex >= 0) {
        if (tabsArray.count == 1) {
            _currentSelectedIndex = NSNotFound;
        } else {
            if ((atIndex < _currentSelectedIndex) ||
                (atIndex == _currentSelectedIndex && atIndex == tabsArray.count - 1)) {
                _currentSelectedIndex -= 1;
            }
        }
    }
    
    [tabsArray x_removeObjectAtIndex:atIndex];
    
    UIButton *removeButton = (UIButton *)[tabBarScrollView viewWithTag:buttonTag(atIndex)];
    UILabel *removeBadge = (UILabel *)[tabBarScrollView viewWithTag:badgeTag(atIndex)];
    [removeButton removeFromSuperview];
    [removeBadge removeFromSuperview];
    
    if ([XTool isArrayEmpty:tabsArray] == NO) {
        for (NSInteger i = atIndex; i < tabsArray.count; i++) {
            UIButton *button = (UIButton *)[tabBarScrollView viewWithTag:buttonTag(i+1)];
            UILabel *badge = (UILabel *)[tabBarScrollView viewWithTag:badgeTag(i+1)];
            [button setTag:buttonTag(i)];
            [badge setTag:badgeTag(i)];
        }
        
        [self updateTabsFrame];
        [self updateTabLineImageViewFrame:0];
    } else {
        _currentSelectedIndex = NSNotFound;
        [self setNeedsLayout];
    }
    [self updateTabLineImageViewState];
}

- (void)removeTabForTitle:(NSString *)title {
    NSInteger index = [tabsArray indexOfObject:title];
    [self removeTabAtIndex:index];
}

- (void)selectTab:(NSInteger)index {
    if (index == NSNotFound || index < 0) {
        return;
    }
    [self changeTabButtonState:index changeColor:YES changeFont:YES];
    [self selectTabWithoutChangeState:index];
}

- (void)adjustToSelectedTabWithScrollView:(UIScrollView *)scrollView beginOffsetX:(CGFloat)beginOffsetX endOffsetX:(CGFloat)endOffsetX {
    CGFloat scrollViewWidth = scrollView.frame.size.width;
    CGFloat scrollViewOffsetX = scrollView.contentOffset.x;
    
    if (scrollViewOffsetX < beginOffsetX || scrollViewOffsetX > endOffsetX) {
        return;
    }
    
    NSInteger index = scrollViewOffsetX / scrollViewWidth;
    
    if (_currentTabBarUpdateStateWay == XTabBarUpdateStateWayByDragScroll) {
        CGFloat scrollOffsetForCurrentView = scrollViewOffsetX - scrollViewWidth * index;
        NSInteger selectedTabIndex = 0;
        CGFloat offsetScale = scrollOffsetForCurrentView * 1.0 / scrollViewWidth;
        if (offsetScale >= 0.5) {
            selectedTabIndex = index + 1;
        } else {
            selectedTabIndex = index;
        }
        if (_currentSelectedIndex != NSNotFound && _currentSelectedIndex >= 0 && _currentSelectedIndex != selectedTabIndex) {
            [self changeTabButtonState:selectedTabIndex changeColor:!_colorAnimated changeFont:!_fontAnimated];
            [self selectTabWithoutChangeState:selectedTabIndex];
        }
        
        [self updateTabLineImageViewFrame:offsetScale];
        if (_colorAnimated == YES) {
            [self autoAdjustTabColor:offsetScale];
        }
        if (_fontAnimated == YES) {
            [self autoAdjustFontSize:offsetScale];
        }
    }
    
    if ((_currentTabBarUpdateStateWay == XTabBarUpdateStateWayByClick ||
         _currentTabBarUpdateStateWay == XTabBarUpdateStateWayByDragScroll) &&
        scrollViewOffsetX == scrollViewWidth * index) {
        _currentTabBarUpdateStateWay = XTabBarUpdateStateWayDefault;
        if(_delegate != nil && [_delegate respondsToSelector:@selector(pageEndScroll:title:)]) {
            [_delegate pageEndScroll:index title:[tabsArray x_objectAtIndex:index]];
        }
    }
}

- (void)updateTabBar {
    [self setNeedsLayout];
}

#pragma mark badge

- (void)setBadgeHidden:(BOOL)hidden forTitle:(NSString *)title {
    UILabel *badge = [self getBadgeForTitle:title];
    if (badge == nil) {
        return;
    }
    [badge setHidden:hidden];
}

- (void)setBadgeHidden:(BOOL)hidden atIndex:(NSInteger)index {
    NSString *title = [tabsArray x_objectAtIndex:index];
    [self setBadgeHidden:hidden forTitle:title];
}

- (void)setBadgeTextForTitle:(NSString *)title badgeText:(NSString *)badgeText {
    UILabel *badge = [self getBadgeForTitle:title];
    if (badge == nil) {
        return;
    }
    [badge setText:badgeText];
    [self updateBadgeFrame:badge];
}

- (void)setBadgeTextAtIndex:(NSInteger)index badgeText:(NSString *)badgeText {
    NSString *title = [tabsArray x_objectAtIndex:index];
    [self setBadgeTextForTitle:title badgeText:badgeText];
}

- (NSString *)getBadgeTextForTitle:(NSString *)title {
    UILabel *badge = [self getBadgeForTitle:title];
    if (badge == nil) {
        return @"";
    }
    return badge.text;
}

- (NSString *)getBadgeTextAtIndex:(NSInteger)index {
    NSString *title = [tabsArray x_objectAtIndex:index];
    return [self getBadgeTextForTitle:title];
}

#pragma mark ---------- Private ----------

#pragma mark method

#pragma mark init

- (void)initialize {
    [self setBackgroundColor:[UIColor whiteColor]];
    _delegate = nil;
    _bounces = YES;
    _showsHorizontalScrollIndicator = NO;
    _maxCountForTabsShown           = 3;
    _currentSelectedIndex           = NSNotFound;
    _currentTabBarUpdateStateWay    = XTabBarUpdateStateWayDefault;
    _separatorHeight                = 2.0f;
    
    _textNormalFont     = [UIFont systemFontOfSize:14];
    _textSelectedFont   = [UIFont systemFontOfSize:14];
    _textNormalColor    = [UIColor blackColor];
    _textSelectedColor  = [UIColor blueColor];
    _separatorColor     = [UIColor whiteColor];
    _tabLineColor       = [UIColor blueColor];
    _tabLineImage       = nil;
    _tabLineHeight      = 1.5f;
    
    _badgeBackgroundColor   = [UIColor redColor];
    _badgeTextColor         = [UIColor whiteColor];
    
    _showTabLine        = YES;
    _colorAnimated      = YES;
    _fontAnimated       = YES;
    
    tabsArray = [[NSMutableArray alloc] init];
    
    [self getColorRGB];
}

- (void)addUI {
    [self addSeparator];
    [self addTabBarScrollView];
    [self addTabLineImageView];
}

- (void)addSeparator {
    separator = [[UIView alloc] init];
    [separator setBackgroundColor:_separatorColor];
    [self addSubview:separator];
}

- (void)addTabBarScrollView {
    tabBarScrollView = [[XScrollView alloc] init];
    [tabBarScrollView setBackgroundColor:[UIColor clearColor]];
    [tabBarScrollView setBounces:_bounces];
    [tabBarScrollView setShowsHorizontalScrollIndicator:_showsHorizontalScrollIndicator];
    [tabBarScrollView setShowsVerticalScrollIndicator:NO];
    [tabBarScrollView setDelaysContentTouches:NO];
    [tabBarScrollView setDelegate:self];
    [self addSubview:tabBarScrollView];
}

- (void)addTabLineImageView {
    tabLineImageView = [[UIImageView alloc] init];
    [tabLineImageView setTag:tabLineImageViewTag];
    [tabLineImageView setBackgroundColor:_tabLineColor];
    [tabLineImageView setImage:_tabLineImage];
    [tabBarScrollView addSubview:tabLineImageView];
}

- (void)addTabToScrollView:(NSString *)title atIndex:(NSInteger)atIndex {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundColor:[UIColor clearColor]];
    NSInteger buttonTag = buttonTag(atIndex);
    [button setTag:buttonTag];
    [button setTitle:title forState:UIControlStateNormal];
    [button.titleLabel setFont:_textNormalFont];
    [button setTitleColor:_textNormalColor forState:UIControlStateNormal];
    [button addTarget:self action:@selector(selectButton:) forControlEvents:UIControlEventTouchUpInside];
    [tabBarScrollView addSubview:button];
    
    UILabel *badge = [[UILabel alloc] init];
    NSInteger badgeTag = badgeTag(atIndex);
    [badge setTag:badgeTag];
    [badge setBackgroundColor:[UIColor clearColor]];
    [badge setTextColor:_badgeTextColor];
    [badge setTextAlignment:NSTextAlignmentCenter];
    [badge setFont:[UIFont fontWithName:@"Helvetica-Bold" size:8]];
    [badge.layer setBackgroundColor:[_badgeBackgroundColor CGColor]];
    [badge setHidden:YES];
    [tabBarScrollView addSubview:badge];
}

- (void)getColorRGB {
    if (_textNormalColor) {
        const CGFloat *normalRGB = [XTool getRGBFromColor:_textNormalColor];
        
        if (normalRGB == NULL || normalRGB == nil) {
            textNormalColorR = -1;
            textNormalColorG = -1;
            textNormalColorB = -1;
        } else {
            textNormalColorR = normalRGB[0];
            textNormalColorG = normalRGB[1];
            textNormalColorB = normalRGB[2];
        }
        
        textNormalAlpha = [XTool getAlphaFromColor:_textNormalColor];
    }
    
    if (_textSelectedColor) {
        const CGFloat *selectedRGB = [XTool getRGBFromColor:_textSelectedColor];
        
        if (selectedRGB == NULL || selectedRGB == nil) {
            textSelectedColorR = -1;
            textSelectedColorG = -1;
            textSelectedColorB = -1;
        } else {
            textSelectedColorR = selectedRGB[0];
            textSelectedColorG = selectedRGB[1];
            textSelectedColorB = selectedRGB[2];
        }
        
        textSelectedAlpha = [XTool getAlphaFromColor:_textSelectedColor];
    }
}

- (void)selectTabWithoutChangeState:(NSInteger)index {
    if (index == NSNotFound || index < 0) {
        return;
    }
    
    [self adjustTabToCenter:index];
    
    BOOL needsLayout = NO;
    if (_currentSelectedIndex == NSNotFound) {
        needsLayout = YES;
    }
    _currentSelectedIndex = index;
    
    if (needsLayout == YES) {
        [self updateTabLineImageViewState];
        [self updateTabsFrame];
    }
}

- (void)autoAdjustTabColor:(CGFloat)offsetScale {
    if (_currentSelectedIndex == NSNotFound || _currentSelectedIndex < 0) {
        return;
    }
    
    UIView *currentView = [tabBarScrollView viewWithTag:buttonTag(_currentSelectedIndex)];
    if (currentView == nil || [currentView isKindOfClass:[UIButton class]] == NO) {
        return;
    }
    
    if (textNormalColorR < 0 || textNormalColorG < 0 || textNormalColorB < 0 || textNormalAlpha < 0 ||
        textSelectedColorR < 0 || textSelectedColorG < 0 || textSelectedColorB < 0 || textSelectedAlpha < 0) {
        return;
    }
    
    CGFloat recoverNewR = textSelectedColorR + (textNormalColorR - textSelectedColorR) * offsetScale;
    CGFloat recoverNewG = textSelectedColorG + (textNormalColorG - textSelectedColorG) * offsetScale;
    CGFloat recoverNewB = textSelectedColorB + (textNormalColorB - textSelectedColorB) * offsetScale;
    CGFloat recoverNewAlpha = textSelectedAlpha + (textNormalAlpha - textSelectedAlpha) * offsetScale;
    UIColor *recoverNewColor = [UIColor colorWithRed:recoverNewR green:recoverNewG blue:recoverNewB alpha:recoverNewAlpha];
    
    CGFloat selectNewR = textNormalColorR + (textSelectedColorR - textNormalColorR) * offsetScale;
    CGFloat selectNewG = textNormalColorG + (textSelectedColorG - textNormalColorG) * offsetScale;
    CGFloat selectNewB = textNormalColorB + (textSelectedColorB - textNormalColorB) * offsetScale;
    CGFloat selectNewAlpha = textNormalAlpha + (textSelectedAlpha - textNormalAlpha) * offsetScale;
    UIColor *selectNewColor = [UIColor colorWithRed:selectNewR green:selectNewG blue:selectNewB alpha:selectNewAlpha];
    
    UIButton *currentButton = (UIButton *)currentView;
    
    if (offsetScale < 0.5) {
        UIView *lastView = [tabBarScrollView viewWithTag:buttonTag(_currentSelectedIndex + 1)];
        if (lastView == nil || [lastView isKindOfClass:[UIButton class]] == NO) {
            return;
        }
        UIButton *lastButton = (UIButton *)lastView;
        
        [currentButton setTitleColor:recoverNewColor forState:UIControlStateNormal];
        [lastButton setTitleColor:selectNewColor forState:UIControlStateNormal];
    } else {
        UIView *lastView = [tabBarScrollView viewWithTag:buttonTag(_currentSelectedIndex - 1)];
        if (lastView == nil || [lastView isKindOfClass:[UIButton class]] == NO) {
            return;
        }
        UIButton *lastButton = (UIButton *)lastView;
        
        [currentButton setTitleColor:selectNewColor forState:UIControlStateNormal];
        [lastButton setTitleColor:recoverNewColor forState:UIControlStateNormal];
    }
}

- (void)autoAdjustFontSize:(CGFloat)offsetScale {
    if (_currentSelectedIndex == NSNotFound || _currentSelectedIndex < 0) {
        return;
    }
    
    if (_textNormalFont == nil || _textSelectedFont == nil) {
        return;
    }
    
    UIView *currentView = [tabBarScrollView viewWithTag:buttonTag(_currentSelectedIndex)];
    if (currentView == nil || [currentView isKindOfClass:[UIButton class]] == NO) {
        return;
    }

    CGFloat recoverNewFontSize = _textSelectedFont.pointSize + (_textNormalFont.pointSize - _textSelectedFont.pointSize) * offsetScale;
    CGFloat selectNewFontSize = _textNormalFont.pointSize + (_textSelectedFont.pointSize - _textNormalFont.pointSize) * offsetScale;

    UIButton *currentButton = (UIButton *)currentView;
    
    if (offsetScale < 0.5) {
        UIView *lastView = [tabBarScrollView viewWithTag:buttonTag(_currentSelectedIndex + 1)];
        if (lastView == nil || [lastView isKindOfClass:[UIButton class]] == NO) {
            return;
        }
        UIButton *lastButton = (UIButton *)lastView;
        
        [currentButton.titleLabel setFont:[UIFont fontWithName:_textSelectedFont.fontName size:recoverNewFontSize]];
        [lastButton.titleLabel setFont:[UIFont fontWithName:_textNormalFont.fontName size:selectNewFontSize]];
    } else {
        UIView *lastView = [tabBarScrollView viewWithTag:buttonTag(_currentSelectedIndex - 1)];
        if (lastView == nil || [lastView isKindOfClass:[UIButton class]] == NO) {
            return;
        }
        UIButton *lastButton = (UIButton *)lastView;
        
        [currentButton.titleLabel setFont:[UIFont fontWithName:_textSelectedFont.fontName size:selectNewFontSize]];
        [lastButton.titleLabel setFont:[UIFont fontWithName:_textNormalFont.fontName size:recoverNewFontSize]];
    }
}

#pragma mark layout

- (void)updateFrame {
    [self updateSeparatorFrame];
    [self updateTabBarScrollViewFrame];
    [self updateTabsFrame];
    [self updateTabLineImageViewFrame:0];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateFrame];
}

- (void)updateSeparatorFrame {
    CGFloat separatorWidth = self.frame.size.width;
    CGFloat separatorX = 0;
    CGFloat separatorY = self.frame.size.height - _separatorHeight;
    [separator setFrame:CGRectMake(separatorX, separatorY, separatorWidth, _separatorHeight)];
}

- (void)updateTabBarScrollViewFrame {
    CGFloat tabBarScrollViewWidth = self.frame.size.width;
    CGFloat tabBarScrollViewHeight = self.frame.size.height - separator.frame.size.height;
    CGFloat tabBarScrollViewX = 0;
    CGFloat tabBarScrollViewY = 0;
    
    [tabBarScrollView setFrame:CGRectMake(tabBarScrollViewX, tabBarScrollViewY, tabBarScrollViewWidth, tabBarScrollViewHeight)];
}

- (void)updateTabLineImageViewFrame:(CGFloat)offsetScale {
    if (_currentSelectedIndex == NSNotFound || _currentSelectedIndex < 0) {
        [self updateTabLineImageViewState];
        return;
    }
    
    if (_showTabLine == NO) {
        return;
    }
    
    UIView *currentView = [tabBarScrollView viewWithTag:buttonTag(_currentSelectedIndex)];
    if (currentView == nil || [currentView isKindOfClass:[UIButton class]] == NO) {
        return;
    }
    
    CGFloat tabLineImageViewWidth = 0;
    CGFloat tabLineImageViewX = 0;
    CGFloat tabLineImageViewY = tabBarScrollView.frame.size.height - _tabLineHeight;
    
    UIButton *currentButton = (UIButton *)currentView;
    CGFloat currentButtonWidth = currentButton.frame.size.width;
    if (offsetScale < 0.5) {
        UIView *lastView = [tabBarScrollView viewWithTag:buttonTag(_currentSelectedIndex + 1)];
        if (lastView == nil || [lastView isKindOfClass:[UIButton class]] == NO) {
            tabLineImageViewWidth = currentButtonWidth;
        } else {
            UIButton *lastButton = (UIButton *)lastView;
            CGFloat WidthDifference = lastButton.frame.size.width - currentButtonWidth;
            tabLineImageViewWidth = currentButtonWidth + WidthDifference * offsetScale;
        }
        tabLineImageViewX = currentButton.frame.origin.x + currentButtonWidth * offsetScale;
    } else {
        UIView *lastView = [tabBarScrollView viewWithTag:buttonTag(_currentSelectedIndex - 1)];
        if (lastView == nil || [lastView isKindOfClass:[UIButton class]] == NO) {
            return;
        } else {
            UIButton *lastButton = (UIButton *)lastView;
            CGFloat lastButtonWidth = lastButton.frame.size.width;
            CGFloat WidthDifference = currentButtonWidth - lastButtonWidth;
            tabLineImageViewWidth = lastButtonWidth + WidthDifference * offsetScale;
            tabLineImageViewX = lastButton.frame.origin.x + lastButtonWidth * offsetScale;
        }
    }
    
    [tabLineImageView setFrame:CGRectMake(tabLineImageViewX, tabLineImageViewY, tabLineImageViewWidth, _tabLineHeight)];
}

- (void)updateTabsFrame {
    CGFloat tabBarScrollViewContentWidth = 0;
    
    if ([XTool isArrayEmpty:tabsArray] == NO) {
        CGFloat halfOffsetBetweenTabs = [self calculateHalfOffsetBetweenTabs];
        
        CGFloat buttonWidth = 0;
        CGFloat buttonHeight = tabBarScrollView.frame.size.height - tabLineImageView.frame.size.height;
        CGFloat buttonX = 0;
        CGFloat buttonY = 0;
        
        for (NSInteger i = 0; i < tabsArray.count; i ++) {
            UIButton *button = (UIButton *)[tabBarScrollView viewWithTag:buttonTag(i)];
            UILabel *badge = (UILabel *)[tabBarScrollView viewWithTag:badgeTag(i)];
            
            buttonWidth = [button.titleLabel labelSize].width + halfOffsetBetweenTabs * 2;
            [button setFrame:CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight)];
            
            CGFloat offset = 4;
            CGFloat badgeWidth = 0;
            
            if ([XTool isStringEmpty:badge.text] == YES) {
                badgeWidth = minBadgeSize;
            } else {
                badgeWidth = maxBadgeSize;
            }
            CGFloat badgeHeight = badgeWidth;
            
            CGFloat badgeX = buttonX + buttonWidth - badgeWidth - offset;
            CGFloat badgeY = buttonY + offset;
            
            [badge setFrame:CGRectMake(badgeX, badgeY, badgeWidth, badgeHeight)];
            [badge.layer setCornerRadius:badgeWidth / 2.0];
            
            buttonX = buttonX + buttonWidth;
            tabBarScrollViewContentWidth = buttonX;
        }
    }
    [tabBarScrollView setContentSize:CGSizeMake(tabBarScrollViewContentWidth, tabBarScrollView.frame.size.height)];
}

- (void)updateBadgeFrame:(UILabel *)badge {
    CGRect badgeFrame = badge.frame;
    
    CGFloat badgeRight = badgeFrame.origin.x + badgeFrame.size.width;
    
    if ([XTool isStringEmpty:badge.text] == YES) {
        badgeFrame.size.width = minBadgeSize;
        badgeFrame.size.height = minBadgeSize;
    } else {
        badgeFrame.size.width = maxBadgeSize;
        badgeFrame.size.height = maxBadgeSize;
    }
    
    badgeFrame.origin.x = badgeRight - badgeFrame.size.width;
    
    [badge setFrame:badgeFrame];
    [badge.layer setCornerRadius:badgeFrame.size.width / 2.0];
}

//calculate half of offset between tabs for datas
- (CGFloat)calculateHalfOffsetBetweenTabs {
    CGFloat halfOffsetBetweenTabs = 0;
    CGFloat minHalfOffsetBetweenTabs = _textNormalFont.pointSize;
    CGFloat totalTitlesWidth = 0;
    CGFloat totalTabsWidth = 0;
    NSInteger index = 0;
    for (NSString *title in tabsArray) {
        CGSize labelSize;
        if (index == _currentSelectedIndex) {
            labelSize = [XTool labelSize:title font:_textSelectedFont];
        } else {
            labelSize = [XTool labelSize:title font:_textNormalFont];
        }
        totalTitlesWidth += labelSize.width;
        totalTabsWidth += (labelSize.width + minHalfOffsetBetweenTabs * 2);
        index++;
    }
    if (totalTabsWidth < tabBarScrollView.frame.size.width) {
        if ([XTool isArrayEmpty:tabsArray] == NO) {
            if (tabsArray.count > _maxCountForTabsShown) {
                halfOffsetBetweenTabs = (tabBarScrollView.frame.size.width - totalTitlesWidth) * 1.0 / (_maxCountForTabsShown * 2);
            } else {
                halfOffsetBetweenTabs = (tabBarScrollView.frame.size.width - totalTitlesWidth) * 1.0 / (tabsArray.count * 2);
            }
        }
    } else {
        halfOffsetBetweenTabs = minHalfOffsetBetweenTabs;
    }
    return halfOffsetBetweenTabs;
}

- (void)updateTabLineImageViewState {
    if (_showTabLine == NO ||
        [XTool isArrayEmpty:tabsArray] == YES ||
        _currentSelectedIndex == NSNotFound || _currentSelectedIndex < 0) {
        [tabLineImageView setHidden:YES];
    } else {
        [tabLineImageView setHidden:NO];
    }
}

//auto adjust selected tab to screen center
- (void)adjustTabToCenter:(NSInteger)index {
    if (index == NSNotFound || index < 0) {
        return;
    }
    
    UIButton *button = (UIButton *)[tabBarScrollView viewWithTag:buttonTag(index)];
    CGFloat offsetBetweenButtonAndSuperLeft = (tabBarScrollView.frame.size.width - button.frame.size.width) / 2.0;
    CGFloat scrollViewContentOffsetX = button.frame.origin.x - offsetBetweenButtonAndSuperLeft;
    
    if (scrollViewContentOffsetX < 0) {
        scrollViewContentOffsetX = 0;
    } else if (scrollViewContentOffsetX > (tabBarScrollView.contentSize.width - tabBarScrollView.frame.size.width)) {
        scrollViewContentOffsetX = tabBarScrollView.contentSize.width - tabBarScrollView.frame.size.width;
    }
    
    CGPoint contentOffset = tabBarScrollView.contentOffset;
    contentOffset.x = scrollViewContentOffsetX;
    [tabBarScrollView setContentOffset:contentOffset animated:YES];
}

- (void)changeTabButtonState:(NSInteger)index changeColor:(BOOL)changeColor changeFont:(BOOL)changeFont {
    if (_currentSelectedIndex != NSNotFound && _currentSelectedIndex >= 0) {
        UIButton *currentButton = (UIButton *)[tabBarScrollView viewWithTag:buttonTag(_currentSelectedIndex)];
        if (changeColor == YES) {
            [currentButton setTitleColor:_textNormalColor forState:UIControlStateNormal];
        }
        if (changeFont == YES) {
            [currentButton.titleLabel setFont:_textNormalFont];
        }
    }
    
    if (index != NSNotFound && index >= 0) {
        UIButton *selectedButton = (UIButton *)[tabBarScrollView viewWithTag:buttonTag(index)];
        if (changeColor == YES) {
            [selectedButton setTitleColor:_textSelectedColor forState:UIControlStateNormal];
        }
        if (changeFont == YES) {
            [selectedButton.titleLabel setFont:_textSelectedFont];
        }
    }
}

- (void)removeAllTabsFromScrollView {
    for (UIView *subView in tabBarScrollView.subviews) {
        if (subView.tag != tabLineImageViewTag) {
            [subView removeFromSuperview];
        }
    }
}

#pragma mark badge

- (UILabel *)getBadgeForTitle:(NSString *)title {
    for (UIView *subView in tabBarScrollView.subviews) {
        if ([subView isKindOfClass:[UIButton class]] == YES) {
            UIButton *button = (UIButton *)subView;
            if ([button.titleLabel.text isEqualToString:title] == YES) {
                NSInteger badgeTag = button.tag - initializeTag + 1;
                UILabel *badge = (UILabel *)[tabBarScrollView viewWithTag:badgeTag];
                return badge;
            }
        }
    }
    return nil;
}

#pragma mark property

- (void)setBounces:(BOOL)bounces {
    _bounces = bounces;
    [tabBarScrollView setBounces:bounces];
}

- (void)setShowsHorizontalScrollIndicator:(BOOL)showsHorizontalScrollIndicator {
    _showsHorizontalScrollIndicator = showsHorizontalScrollIndicator;
    [tabBarScrollView setShowsHorizontalScrollIndicator:_showsHorizontalScrollIndicator];
}

- (void)setMaxCountForTabsShown:(NSInteger)maxCountForTabsShown {
    _maxCountForTabsShown = maxCountForTabsShown;
    [self setNeedsLayout];
}

- (void)setCurrentSelectedIndex:(NSInteger)currentSelectedIndex {
    _currentSelectedIndex = currentSelectedIndex;
    [self selectTab:_currentSelectedIndex];
    [self updateTabLineImageViewFrame:0];
}

- (void)setSeparatorHeight:(CGFloat)separatorHeight {
    _separatorHeight = separatorHeight;
    [self setNeedsLayout];
}

- (void)setSeparatorColor:(UIColor *)separatorColor {
    _separatorColor = separatorColor;
    [separator setBackgroundColor:separatorColor];
}

- (void)setTextNormalFont:(UIFont *)textNormalFont {
    _textNormalFont = textNormalFont;
    if ([XTool isArrayEmpty:tabsArray] == NO) {
        for (NSInteger i = 0; i < tabsArray.count; i ++) {
            UIButton *button = (UIButton *)[tabBarScrollView viewWithTag:buttonTag(i)];
            if (i != _currentSelectedIndex) {
                [button.titleLabel setFont:_textNormalFont];
            }
        }
    }
}

- (void)setTextSelectedFont:(UIFont *)textSelectedFont {
    _textSelectedFont = textSelectedFont;
    if (_currentSelectedIndex == NSNotFound || _currentSelectedIndex < 0) {
        return;
    }
    if ([XTool isArrayEmpty:tabsArray] == NO) {
        UIButton *button = (UIButton *)[tabBarScrollView viewWithTag:buttonTag(_currentSelectedIndex)];
        [button.titleLabel setFont:_textSelectedFont];
    }
}

- (void)setTextNormalColor:(UIColor *)textNormalColor {
    _textNormalColor = textNormalColor;
    
    [self getColorRGB];
    
    if ([XTool isArrayEmpty:tabsArray] == NO) {
        for (NSInteger i = 0; i < tabsArray.count; i ++) {
            UIButton *button = (UIButton *)[tabBarScrollView viewWithTag:buttonTag(i)];
            if (i != _currentSelectedIndex) {
                [button setTitleColor:_textNormalColor forState:UIControlStateNormal];
            }
        }
    }
}

- (void)setTextSelectedColor:(UIColor *)textSelectedColor {
    _textSelectedColor = textSelectedColor;
    
    [self getColorRGB];
    
    if (_currentSelectedIndex == NSNotFound || _currentSelectedIndex < 0) {
        return;
    }
    if ([XTool isArrayEmpty:tabsArray] == NO) {
        UIButton *button = (UIButton *)[tabBarScrollView viewWithTag:buttonTag(_currentSelectedIndex)];
        [button setTitleColor:_textSelectedColor forState:UIControlStateNormal];
    }
}

- (void)setTabLineColor:(UIColor *)tabLineColor {
    _tabLineColor = tabLineColor;
    [tabLineImageView setBackgroundColor:_tabLineColor];
}

- (void)setTabLineImage:(UIImage *)tabLineImage {
    _tabLineImage = tabLineImage;
    [tabLineImageView setImage:tabLineImage];
}

- (void)setTabLineHeight:(CGFloat)tabLineHeight {
    _tabLineHeight = tabLineHeight;
    [self setNeedsLayout];
}

- (void)setBadgeBackgroundColor:(UIColor *)badgeBackgroundColor {
    _badgeBackgroundColor = badgeBackgroundColor;
    for (NSString *title in tabsArray) {
        UILabel *badge = [self getBadgeForTitle:title];
        [badge.layer setBackgroundColor:[_badgeBackgroundColor CGColor]];
    }
}

- (void)setBadgeTextColor:(UIColor *)badgeTextColor {
    _badgeTextColor = badgeTextColor;
    for (NSString *title in tabsArray) {
        UILabel *badge = [self getBadgeForTitle:title];
        [badge setTextColor:_badgeTextColor];
    }
}

- (void)setShowTabLine:(BOOL)showTabLine {
    _showTabLine = showTabLine;
    [self updateTabLineImageViewState];
    [self updateTabLineImageViewFrame:0];
}

#pragma mark TabBarEvent Method

- (void)selectButton:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSInteger index = (button.tag - initializeTag) / 2;
    _currentTabBarUpdateStateWay = XTabBarUpdateStateWayByClick;
    if (_currentSelectedIndex != index) {
        [self selectTab:index];
        [self updateTabLineImageViewFrame:0];
    }
    if(_delegate != nil && [_delegate respondsToSelector:@selector(selectTab:atIndex:)]) {
        [_delegate selectTab:button.titleLabel.text atIndex:index];
    }
}

@end
