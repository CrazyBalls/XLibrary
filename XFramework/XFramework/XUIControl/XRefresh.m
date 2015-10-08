//
//  XRefresh.m
//  XFramework
//
//  Created by XJY on 15-7-28.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import "XRefresh.h"
#import "MJRefresh.h"

@implementation UIScrollView (XRefresh)

#pragma mark private property

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

id  actionTarget;
SEL headerRefreshing;
SEL footerRefreshing;

BOOL _allowHeaderAndFooterRefreshingAtTheSameTime = NO;

#pragma mark ---------- Private ----------

- (BOOL)allowHeaderAndFooterRefreshingAtTheSameTime {
    return _allowHeaderAndFooterRefreshingAtTheSameTime;
}

- (void)setAllowHeaderAndFooterRefreshingAtTheSameTime:(BOOL)allowHeaderAndFooterRefreshingAtTheSameTime {
    _allowHeaderAndFooterRefreshingAtTheSameTime = allowHeaderAndFooterRefreshingAtTheSameTime;
}

- (void)headerRefreshingAction {
    if ([self isAllowRefresh:XRefreshingTypeHeader] == YES) {
        SuppressPerformSelectorLeakWarning(
                                           [actionTarget performSelector:headerRefreshing]
                                           );
    }
}

- (void)footerRefreshingAction {
    if ([self isAllowRefresh:XRefreshingTypeFooter] == YES) {
        SuppressPerformSelectorLeakWarning(
                                           [actionTarget performSelector:footerRefreshing]
                                           );
    }
}

- (void)setHeaderTitle:(NSString *)title forState:(MJRefreshState)state {
    MJRefreshStateHeader *header = (MJRefreshStateHeader *)self.header;
    [header setTitle:title forState:state];
}

- (void)setFooterTitle:(NSString *)title forState:(MJRefreshState)state {
    if ([self.footer isKindOfClass:[MJRefreshAutoStateFooter class]] == YES) {
        MJRefreshAutoStateFooter *footer = (MJRefreshAutoStateFooter *)self.footer;
        [footer setTitle:title forState:state];
    } else if ([self.footer isKindOfClass:[MJRefreshBackStateFooter class]] == YES) {
        MJRefreshBackStateFooter *footer = (MJRefreshBackStateFooter *)self.footer;
        [footer setTitle:title forState:state];
    }
}

#pragma mark ---------- Public ----------

#pragma mark add refresh

- (void)headerWithRefreshingTarget:(id)target refreshingAction:(SEL)action {
    actionTarget = target;
    headerRefreshing = action;
    
    self.header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshingAction)];
    [self setRefreshAutoChangeAlpha:YES forRefresh:XRefreshingTypeHeader];
}

- (void)headerWithRefreshingBlock:(void (^)())block {
    __block UIScrollView *b_Self = self;
    self.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        if ([b_Self isAllowRefresh:XRefreshingTypeHeader] == YES) {
            block();
        }
    }];
    [self setRefreshAutoChangeAlpha:YES forRefresh:XRefreshingTypeHeader];
}

- (void)footerWithRefreshingTarget:(id)target refreshingAction:(SEL)action {
    actionTarget = target;
    footerRefreshing = action;
    
    self.footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshingAction)];
    
    [self setFooterRefreshAutomaticallyRefresh:NO];
}

- (void)footerWithRefreshingBlock:(void (^)())block {
    __block UIScrollView *b_Self = self;
    
    self.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        if ([b_Self isAllowRefresh:XRefreshingTypeFooter] == YES) {
            block();
        }
    }];
    
    [self setFooterRefreshAutomaticallyRefresh:NO];
}

- (void)footerBackWithRefreshingTarget:(id)target refreshingAction:(SEL)action {
    actionTarget = target;
    footerRefreshing = action;
    
    self.footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshingAction)];
    
    [self setRefreshAutoChangeAlpha:YES forRefresh:XRefreshingTypeFooter];
}

- (void)footerBackWithRefreshingBlock:(void (^)())block {
    __block UIScrollView *b_Self = self;
    
    self.footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        if ([b_Self isAllowRefresh:XRefreshingTypeFooter] == YES) {
            block();
        }
    }];
    
    [self setRefreshAutoChangeAlpha:YES forRefresh:XRefreshingTypeFooter];
}

#pragma mark set title

- (void)setRefreshTitleForStateIdle:(NSString *)title forRefresh:(XRefreshingType)refreshingType {
    if (refreshingType == XRefreshingTypeHeader) {

        [self setHeaderTitle:title forState:MJRefreshStateIdle];

    } else if (refreshingType == XRefreshingTypeFooter) {
        
        [self setFooterTitle:title forState:MJRefreshStateIdle];

    } else if (refreshingType == (XRefreshingTypeHeader | XRefreshingTypeFooter)) {
        
        [self setHeaderTitle:title forState:MJRefreshStateIdle];
        [self setFooterTitle:title forState:MJRefreshStateIdle];

    }
}

- (void)setRefreshTitleForStatePulling:(NSString *)title forRefresh:(XRefreshingType)refreshingType {
    if (refreshingType == XRefreshingTypeHeader) {

        [self setHeaderTitle:title forState:MJRefreshStatePulling];

    } else if (refreshingType == XRefreshingTypeFooter) {
        
        [self setFooterTitle:title forState:MJRefreshStatePulling];

    } else if (refreshingType == (XRefreshingTypeHeader | XRefreshingTypeFooter)) {

        [self setHeaderTitle:title forState:MJRefreshStatePulling];
        [self setFooterTitle:title forState:MJRefreshStatePulling];
        
    }
}

- (void)setRefreshTitleForStateRefreshing:(NSString *)title forRefresh:(XRefreshingType)refreshingType {
    if (refreshingType == XRefreshingTypeHeader) {

        [self setHeaderTitle:title forState:MJRefreshStateRefreshing];

    } else if (refreshingType == XRefreshingTypeFooter) {
        
        [self setFooterTitle:title forState:MJRefreshStateRefreshing];

    } else if (refreshingType == (XRefreshingTypeHeader | XRefreshingTypeFooter)) {

        [self setHeaderTitle:title forState:MJRefreshStateRefreshing];
        [self setFooterTitle:title forState:MJRefreshStateRefreshing];

    }
}

- (void)setRefreshTitleForStateWillRefresh:(NSString *)title forRefresh:(XRefreshingType)refreshingType {
    if (refreshingType == XRefreshingTypeHeader) {

        [self setHeaderTitle:title forState:MJRefreshStateWillRefresh];

    } else if (refreshingType == XRefreshingTypeFooter) {

        [self setFooterTitle:title forState:MJRefreshStateWillRefresh];

    } else if (refreshingType == (XRefreshingTypeHeader | XRefreshingTypeFooter)) {

        [self setHeaderTitle:title forState:MJRefreshStateWillRefresh];
        [self setFooterTitle:title forState:MJRefreshStateWillRefresh];

    }
}

- (void)setFooterRefreshTitleForStateNoMoreData:(NSString *)title {
    [self setFooterTitle:title forState:MJRefreshStateNoMoreData];
}

#pragma mark begin & end refreshing

- (void)beginRefresh:(XRefreshingType)refreshingType {
    if (refreshingType == XRefreshingTypeHeader) {
        [self.header beginRefreshing];
    } else if (refreshingType == XRefreshingTypeFooter) {
        [self.footer beginRefreshing];
    } else if (refreshingType == (XRefreshingTypeHeader | XRefreshingTypeFooter)) {
        [self.header beginRefreshing];
        [self.footer beginRefreshing];
    }
}

- (void)endRefresh:(XRefreshingType)refreshingType {
    if (refreshingType == XRefreshingTypeHeader) {
        [self.header endRefreshing];
    } else if (refreshingType == XRefreshingTypeFooter) {
        [self.footer endRefreshing];
    } else if (refreshingType == (XRefreshingTypeHeader | XRefreshingTypeFooter)) {
        [self.header endRefreshing];
        [self.footer endRefreshing];
    }
}

- (void)endAllRefresh {
    if ([self isRefreshing:XRefreshingTypeHeader] == YES) {
        [self endRefresh:XRefreshingTypeHeader];
    }
    if ([self isRefreshing:XRefreshingTypeFooter] == YES) {
        [self endRefresh:XRefreshingTypeFooter];
    }
}

#pragma mark other method

- (BOOL)isAllowRefresh:(XRefreshingType)refreshingType {
    if (_allowHeaderAndFooterRefreshingAtTheSameTime == NO) {
        BOOL isAllowRefresh = NO;
        if (refreshingType == XRefreshingTypeHeader) {
            if ([self isRefreshing:XRefreshingTypeFooter] == YES) {
                isAllowRefresh = NO;
                [self endRefresh:XRefreshingTypeHeader];
            } else {
                isAllowRefresh = YES;
            }
        } else if (refreshingType == XRefreshingTypeFooter) {
            if ([self isRefreshing:XRefreshingTypeHeader] == YES) {
                isAllowRefresh = NO;
                [self endRefresh:XRefreshingTypeFooter];
            } else {
                isAllowRefresh = YES;
            }
        }
        return isAllowRefresh;
    } else {
        return _allowHeaderAndFooterRefreshingAtTheSameTime;
    }
}

- (BOOL)isRefreshing:(XRefreshingType)refreshingType {
    BOOL isRefreshing = NO;
    if (refreshingType == XRefreshingTypeHeader) {
        isRefreshing = self.header.isRefreshing;
    } else if (refreshingType == XRefreshingTypeFooter) {
        isRefreshing = self.footer.isRefreshing;
    } else if (refreshingType == (XRefreshingTypeHeader | XRefreshingTypeFooter)) {
        isRefreshing = self.header.isRefreshing | self.footer.isRefreshing;
    }
    return isRefreshing;
}

- (void)resetRefreshState:(XRefreshingType)refreshingType {
    if (refreshingType == XRefreshingTypeHeader) {
        [self.header setState:MJRefreshStateIdle];
    } else if (refreshingType == XRefreshingTypeFooter) {
        [self.footer setState:MJRefreshStateIdle];
    } else if (refreshingType == (XRefreshingTypeHeader | XRefreshingTypeFooter)) {
        [self resetAllRefreshState];
    }
}

- (void)resetAllRefreshState {
    [self.header setState:MJRefreshStateIdle];
    [self.footer setState:MJRefreshStateIdle];
}

- (void)setFooterRefreshAutomaticallyRefresh:(BOOL)automaticallyRefresh {
    if ([self.footer isKindOfClass:[MJRefreshAutoFooter class]] == YES) {
        MJRefreshAutoFooter *footer = (MJRefreshAutoFooter *)self.footer;
        [footer setAutomaticallyRefresh:automaticallyRefresh];
    }
}

- (void)setRefreshAutoChangeAlpha:(BOOL)autoChangeAlpha forRefresh:(XRefreshingType)refreshingType {
    if (refreshingType == XRefreshingTypeHeader) {
        [self.header setAutomaticallyChangeAlpha:autoChangeAlpha];
    } else if (refreshingType == XRefreshingTypeFooter) {
        [self.footer setAutomaticallyChangeAlpha:autoChangeAlpha];
    } else if (refreshingType == (XRefreshingTypeHeader | XRefreshingTypeFooter)) {
        [self.header setAutomaticallyChangeAlpha:autoChangeAlpha];
        [self.footer setAutomaticallyChangeAlpha:autoChangeAlpha];
    }
}

- (void)setRefreshHidden:(XRefreshingType)refreshingType hidden:(BOOL)hidden {
    if (refreshingType == XRefreshingTypeHeader) {
        if (self.header.hidden != hidden) {
            [self.header setHidden:hidden];
        }
    } else if (refreshingType == XRefreshingTypeFooter) {
        if (self.footer.hidden != hidden) {
            [self.footer setHidden:hidden];
        }
    } else if (refreshingType == (XRefreshingTypeHeader | XRefreshingTypeFooter)) {
        if (self.header.hidden != hidden) {
            [self.header setHidden:hidden];
        }
        if (self.footer.hidden != hidden) {
            [self.footer setHidden:hidden];
        }
    }
}

- (void)noticeNoMoreData {
    [self.footer noticeNoMoreData];
}

- (BOOL)isNoMoreData {
    if (self.footer.state == MJRefreshStateNoMoreData) {
        return YES;
    } else {
        return NO;
    }
}

@end
