//
//  XProgress.h
//  XFramework
//
//  Created by XJY on 15/9/10.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, XProgressTextAlignment) {
    XProgressTextAlignmentCenter  =   0,
    XProgressTextAlignmentLeft,
    XProgressTextAlignmentRight,
    XProgressTextAlignmentTop,
    XProgressTextAlignmentBottom
};

typedef enum {
    /** Opacity animation */
    XProgressAnimationFade,
    /** Opacity + scale animation */
    XProgressAnimationZoom,
    XProgressAnimationZoomOut = XProgressAnimationZoom,
    XProgressAnimationZoomIn
} XProgressAnimation;

@protocol XProgressDelegate;

@interface XProgress : UIView

typedef void (^XProgressCompletionBlock)();

@property (nonatomic, assign) id<XProgressDelegate> delegate;

@property (nonatomic, assign)   CGFloat     progress;

@property (nonatomic, strong)   UIColor *   indicatorColor;
@property (nonatomic, strong)   UIColor *   indicatorBackgroundColor;
@property (nonatomic, assign)   CGFloat     indicatorWidth;
@property (nonatomic, assign)   CGFloat     indicatorRadius;

@property (nonatomic, assign)   XProgressTextAlignment  verticalTextAlignment;
@property (nonatomic, assign)   XProgressTextAlignment  horizontalTextAlignment;

@property (nonatomic, assign)   CGFloat     offsetBetweenTextAndDetail;

@property (nonatomic, strong)   UIColor     *   textColor;
@property (nonatomic, strong)   UIFont      *   textFont;
@property (nonatomic, copy)     NSString    *   text;

@property (nonatomic, strong)   UIColor     *   detailColor;
@property (nonatomic, strong)   UIFont      *   detailFont;
@property (nonatomic, copy)     NSString    *   detail;

@property (nonatomic, strong)   UILabel     *   textLabel;
@property (nonatomic, strong)   UILabel     *   detailLabel;

@property (nonatomic, assign)   XProgressAnimation  animationType;

- (void)show:(BOOL)animated;

- (void)hide:(BOOL)animated;

- (void)showWhileExecuting:(SEL)method onTarget:(id)target withObject:(id)object animated:(BOOL)animated;

- (void)show:(BOOL)animated whileExecutingBlock:(dispatch_block_t)block completionBlock:(void (^)())completion;

- (void)show:(BOOL)animated onQueue:(dispatch_queue_t)queue whileExecutingBlock:(dispatch_block_t)block completionBlock:(XProgressCompletionBlock)completion;

@end

@protocol XProgressDelegate <NSObject>

@optional

- (void)xProgressWasHidden:(XProgress *)hud;

@end
