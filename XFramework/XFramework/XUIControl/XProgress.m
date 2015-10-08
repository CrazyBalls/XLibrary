//
//  XProgress.m
//  XFramework
//
//  Created by XJY on 15/9/10.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import "XProgress.h"
#import "XLabel.h"
#import "XTool.h"
#import "XIOSVersion.h"

@interface XProgress () {
    NSArray *observableKeypaths;
    CGAffineTransform rotationTransform;
    
    BOOL useAnimation;
    SEL methodForExecution;
    id targetForExecution;
    id objectForExecution;
    XProgressCompletionBlock completionBlock;
}

@end

@implementation XProgress

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initProgress];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initProgress];
    }
    return self;
}

- (void)initProgress {
    [self initialize];
    [self registerForNotifications];
    [self registerForKVO];
    [self addUI];
}

- (void)dealloc {
    [self unregisterFromNotifications];
    [self unregisterFromKVO];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();

    //draw background
    if (_indicatorBackgroundColor != nil) {
        CGContextSetStrokeColorWithColor(context, [_indicatorBackgroundColor CGColor]);
        CGContextSetLineWidth(context, _indicatorWidth);
        CGContextAddArc(context, self.bounds.size.width / 2.0, self.bounds.size.height / 2.0, _indicatorRadius, 0, 2 * M_PI, 0);
        CGContextDrawPath(context, kCGPathStroke);
    }

    //draw indicator
    if (_indicatorColor != nil) {
        CGContextSetStrokeColorWithColor(context, [_indicatorColor CGColor]);
        CGContextSetLineWidth(context, _indicatorWidth);
        
        CGContextAddArc(context, self.bounds.size.width / 2.0, self.bounds.size.height / 2.0, _indicatorRadius, 0, _progress * 2 * M_PI, 0);
        CGContextDrawPath(context, kCGPathStroke);
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

    UIView *parent = self.superview;
    [self setFrame:CGRectMake(0, 0, parent.bounds.size.width, parent.bounds.size.height)];
    
    CGFloat indicatorWidth = (_indicatorRadius + _indicatorWidth) * 2;
    CGFloat indicatorHeight = indicatorWidth;
    CGFloat indicatorX = (self.bounds.size.width - indicatorWidth) / 2.0;
    CGFloat indicatorY = (self.bounds.size.height - indicatorHeight) / 2.0;
    
    CGFloat textLabelWidth = 0;
    CGFloat textLabelHeight = 0;
    CGFloat textLabelX = 0;
    CGFloat textLabelY = 0;
    if ([XTool isStringEmpty:_textLabel.text] == NO) {
        textLabelWidth = [_textLabel labelSize].width;
        textLabelHeight = [_textLabel heightForWidth:textLabelWidth];
    }
    
    CGFloat detailLabelWidth = 0;
    CGFloat detailLabelHeight = 0;
    CGFloat detailLabelX = 0;
    CGFloat detailLabelY = 0;
    if ([XTool isStringEmpty:_detailLabel.text] == NO) {
        detailLabelWidth = [_detailLabel labelSize].width;
        detailLabelHeight = [_detailLabel heightForWidth:detailLabelWidth];
    }

    if (_horizontalTextAlignment == XProgressTextAlignmentCenter) {
        textLabelX = indicatorX + (indicatorWidth - textLabelWidth) / 2.0;
        detailLabelX = indicatorX + (indicatorWidth - detailLabelWidth) / 2.0;
    } else if (_horizontalTextAlignment == XProgressTextAlignmentLeft) {
        textLabelX = indicatorX + _indicatorWidth;
        detailLabelX = indicatorX + _indicatorWidth;
    } else if (_horizontalTextAlignment == XProgressTextAlignmentRight) {
        textLabelX = self.bounds.size.width - indicatorX - _indicatorWidth - textLabelWidth;
        detailLabelX = self.bounds.size.width - indicatorX - _indicatorWidth - detailLabelWidth;
    }
    
    if (_verticalTextAlignment == XProgressTextAlignmentCenter) {
        textLabelY = indicatorY + (indicatorHeight - textLabelHeight) / 2.0;
        detailLabelY = textLabelY + textLabelHeight + _offsetBetweenTextAndDetail;
    } else if (_verticalTextAlignment == XProgressTextAlignmentTop) {
        textLabelY = indicatorY + indicatorWidth;
        detailLabelY = textLabelY + textLabelHeight + _offsetBetweenTextAndDetail;
    } else if (_verticalTextAlignment == XProgressTextAlignmentBottom) {
        detailLabelY = self.bounds.size.height - indicatorHeight - indicatorWidth - detailLabelHeight;
        textLabelY = detailLabelY - _offsetBetweenTextAndDetail - textLabelHeight;
    }

    [_textLabel setFrame:CGRectMake(textLabelX, textLabelY, textLabelWidth, textLabelHeight)];
    [_detailLabel setFrame:CGRectMake(detailLabelX, detailLabelY, detailLabelWidth, detailLabelHeight)];
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    [_textLabel setTextColor:_textColor];
}

- (void)setDetailColor:(UIColor *)detailColor {
    _detailColor = detailColor;
    [_detailLabel setTextColor:_detailColor];
}

- (void)initialize {
    [self setBackgroundColor:[UIColor clearColor]];
    [self setAlpha:0.0];
    
    rotationTransform = CGAffineTransformIdentity;
    useAnimation = NO;
    methodForExecution = nil;
    targetForExecution = nil;
    objectForExecution = nil;
    completionBlock = nil;
    
    _progress = 0;
    
    _indicatorColor = [UIColor blueColor];
    _indicatorBackgroundColor = [UIColor whiteColor];
    _indicatorWidth = 5;
    _indicatorRadius = 50;
    
    _verticalTextAlignment = XProgressTextAlignmentCenter;
    _horizontalTextAlignment = XProgressTextAlignmentCenter;
    
    _offsetBetweenTextAndDetail = 0;
    
    _textColor = [UIColor whiteColor];
    _textFont = [UIFont fontWithName:@"Helvetica" size:17];
    _text = @"";
    
    _detailColor = [UIColor whiteColor];
    _detailFont = [UIFont fontWithName:@"Helvetica" size:15];
    _detail = @"";
    
    _animationType = XProgressAnimationZoomIn;
    
    observableKeypaths = @[
                           @"progress",
                           @"text",
                           @"detail",
                           @"indicatorColor",
                           @"indicatorBackgroundColor",
                           @"indicatorWidth",
                           @"indicatorRadius",
                           @"verticalTextAlignment",
                           @"horizontalTextAlignment",
                           @"textFont",
                           @"detailFont",
                           @"offsetBetweenTextAndDetail"
                           ];
}

- (void)registerForKVO {
    for (NSString *key in observableKeypaths) {
        [self addObserver:self forKeyPath:key options:NSKeyValueObservingOptionNew context:NULL];
    }
}

- (void)unregisterFromKVO {
    for (NSString *key in observableKeypaths) {
        [self removeObserver:self forKeyPath:key];
    }
}

- (void)registerForNotifications {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self selector:@selector(statusBarOrientationDidChange:)
               name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)unregisterFromNotifications {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)didMoveToSuperview {
    [self updateForCurrentOrientationAnimated:NO];
}

- (void)statusBarOrientationDidChange:(NSNotification *)notification {
    UIView *superview = self.superview;
    if (!superview) {
        return;
    } else {
        [self updateForCurrentOrientationAnimated:YES];
    }
}

- (void)updateForCurrentOrientationAnimated:(BOOL)animated {
    // Stay in sync with the superview in any case
    if (self.superview) {
        self.bounds = self.superview.bounds;
        [self setNeedsDisplay];
    }
    
    // Not needed on iOS 8+, compile out when the deployment target allows,
    // to avoid sharedApplication problems on extension targets
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 80000
    // Only needed pre iOS 7 when added to a window
    BOOL iOS8OrLater = [XIOSVersion isIOS8OrGreater];
    if (iOS8OrLater || ![self.superview isKindOfClass:[UIWindow class]])
        return;
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGFloat radians = 0;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        if (orientation == UIInterfaceOrientationLandscapeLeft) { radians = -(CGFloat)M_PI_2; }
        else { radians = (CGFloat)M_PI_2; }
        // Window coordinates differ!
        self.bounds = CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.width);
    } else {
        if (orientation == UIInterfaceOrientationPortraitUpsideDown) { radians = (CGFloat)M_PI; }
        else { radians = 0; }
    }
    rotationTransform = CGAffineTransformMakeRotation(radians);
    
    if (animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
    }
    [self setTransform:rotationTransform];
    if (animated) {
        [UIView commitAnimations];
    }
#endif
}

- (void)addUI {
    _textLabel = [[UILabel alloc] init];
    [_textLabel setBackgroundColor:[UIColor clearColor]];
    [_textLabel setTextAlignment:NSTextAlignmentCenter];
    [_textLabel setTextColor:_textColor];
    [_textLabel setFont:_textFont];
    [_textLabel setText:_text];
    [_textLabel allowMultiLine];
    [self addSubview:_textLabel];
    
    _detailLabel = [[UILabel alloc] init];
    [_detailLabel setBackgroundColor:[UIColor clearColor]];
    [_detailLabel setTextAlignment:NSTextAlignmentCenter];
    [_detailLabel setTextColor:_detailColor];
    [_detailLabel setFont:_detailFont];
    [_detailLabel setText:_detail];
    [_detailLabel allowMultiLine];
    [self addSubview:_detailLabel];
}

- (void)showUsingAnimation:(BOOL)animated {
    // Cancel any scheduled hideDelayed: calls
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self setNeedsDisplay];
    
    if (animated == YES && _animationType == XProgressAnimationZoomIn) {
        self.transform = CGAffineTransformConcat(rotationTransform, CGAffineTransformMakeScale(0.5f, 0.5f));
    } else if (animated && _animationType == XProgressAnimationZoomOut) {
        self.transform = CGAffineTransformConcat(rotationTransform, CGAffineTransformMakeScale(1.5f, 1.5f));
    }
    
    if (animated == YES) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.30];
        [self setAlpha:1.0f];
        if (_animationType == XProgressAnimationZoomIn || _animationType == XProgressAnimationZoomOut) {
            self.transform = rotationTransform;
        }
        [UIView commitAnimations];
    } else {
        [self setAlpha:1.0f];
    }
}

- (void)hideUsingAnimation:(BOOL)animated {
    if (animated == YES) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.30];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
        // 0.02 prevents the progress view from passing through touches during the animation the progress view will get completely hidden
        // in the done method
        if (_animationType == XProgressAnimationZoomIn) {
            self.transform = CGAffineTransformConcat(rotationTransform, CGAffineTransformMakeScale(1.5f, 1.5f));
        } else if (_animationType == XProgressAnimationZoomOut) {
            self.transform = CGAffineTransformConcat(rotationTransform, CGAffineTransformMakeScale(0.5f, 0.5f));
        }
        
        [self setAlpha:0.02f];
        [UIView commitAnimations];
    }
    else {
        [self setAlpha:0.0f];
        [self done];
    }
}

- (void)animationFinished:(NSString *)animationID finished:(BOOL)finished context:(void*)context {
    [self done];
}

- (void)done {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self setAlpha:0.0f];
    
    if (completionBlock) {
        completionBlock();
        completionBlock = nil;
    }
    if(_delegate != nil && [_delegate respondsToSelector:@selector(xProgressWasHidden:)]) {
        [_delegate xProgressWasHidden:self];
    }
}

- (void)launchExecution {
    @autoreleasepool {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        // Start executing the requested task
        [targetForExecution performSelector:methodForExecution withObject:objectForExecution];
#pragma clang diagnostic pop
        // Task completed, update view in main thread (note: view operations should
        // be done only in the main thread)
        [self performSelectorOnMainThread:@selector(cleanUp) withObject:nil waitUntilDone:NO];
    }
}

- (void)cleanUp {
    methodForExecution = nil;
    targetForExecution = nil;
    objectForExecution = nil;
    [self hide:useAnimation];
}

#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"progress"] == YES ||
        [keyPath isEqualToString:@"indicatorColor"] == YES ||
        [keyPath isEqualToString:@"indicatorBackgroundColor"] == YES ||
        [keyPath isEqualToString:@"indicatorWidth"] == YES ||
        [keyPath isEqualToString:@"indicatorRadius"] == YES
        )
    {
        [self setNeedsDisplay];
    }
    
    else if ([keyPath isEqualToString:@"verticalTextAlignment"] == YES ||
               [keyPath isEqualToString:@"horizontalTextAlignment"] == YES ||
               [keyPath isEqualToString:@"offsetBetweenTextAndDetail"] == YES)
    {
        [self setNeedsLayout];
    }
    
    else if ([keyPath isEqualToString:@"textFont"] == YES)
    {
        [_textLabel setFont:_textFont];
        [self setNeedsLayout];
    }
    
    else if ([keyPath isEqualToString:@"detailFont"] == YES)
    {
        [_detailLabel setFont:_detailFont];
        [self setNeedsLayout];
    }
    
    else if ([keyPath isEqualToString:@"text"] == YES)
    {
        [_textLabel setText:_text];
        [self setNeedsLayout];
    }
    
    else if ([keyPath isEqualToString:@"detail"] == YES)
    {
        [_detailLabel setText:_detail];
        [self setNeedsLayout];
    }
}

#pragma mark Public Method

- (void)show:(BOOL)animated {
    [self showUsingAnimation:animated];
}

- (void)hide:(BOOL)animated {
    [self hideUsingAnimation:animated];
}

- (void)showWhileExecuting:(SEL)method onTarget:(id)target withObject:(id)object animated:(BOOL)animated {
    methodForExecution = method;
    targetForExecution = target;
    objectForExecution = object;
    // Launch execution in new thread
    [NSThread detachNewThreadSelector:@selector(launchExecution) toTarget:self withObject:nil];
    // Show progress view
    [self show:animated];
}

- (void)show:(BOOL)animated whileExecutingBlock:(dispatch_block_t)block completionBlock:(void (^)())completion {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    [self show:animated onQueue:queue whileExecutingBlock:block completionBlock:completion];
}

- (void)show:(BOOL)animated onQueue:(dispatch_queue_t)queue whileExecutingBlock:(dispatch_block_t)block completionBlock:(XProgressCompletionBlock)completion {
    completionBlock = completion;
    dispatch_async(queue, ^(void) {
        block();
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self cleanUp];
        });
    });
    [self show:animated];
}

@end
