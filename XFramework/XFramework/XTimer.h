//
//  XTimer.h
//  XFramework
//
//  Created by XJY on 15-7-26.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef dispatch_source_t   XGCDTimer;
typedef uint64_t            XTimeInteger;

typedef void (^TimerBeginBlock)     (XTimeInteger timerProgress);
typedef void (^TimerProgressBlock)  (XTimeInteger timerProgress);
typedef void (^TimerFinishedBlock)  (XTimeInteger timerProgress);
typedef void (^TimerStopBlock)      (XTimeInteger timerProgress);

typedef NS_ENUM(XTimeInteger, XTimeType) {
    XTimeTypeMSec   =   NSEC_PER_MSEC,
    XTimeTypeSec    =   NSEC_PER_SEC
};

typedef NS_ENUM(NSInteger, XTimeDirection) {
    XTimeDirectionIncrease = 0,
    XTimeDirectionDecrease
};

@interface XTimer : NSObject

/**
 启动定时器, 毫秒级, 有超时, 加计数
 */
- (XGCDTimer)startTimerMSecIncreaseWithTimeout:(XTimeInteger)timeout perTime:(XTimeInteger)perTime begin:(TimerBeginBlock)beginBlock progress:(TimerProgressBlock)progressBlock finished:(TimerFinishedBlock)finishedBlock stop:(TimerStopBlock)stopBlock;

/**
 启动定时器, 毫秒级, 有超时, 减计数
 */
- (XGCDTimer)startTimerMSecDecreaseWithTimeout:(XTimeInteger)timeout perTime:(XTimeInteger)perTime begin:(TimerBeginBlock)beginBlock progress:(TimerProgressBlock)progressBlock finished:(TimerFinishedBlock)finishedBlock stop:(TimerStopBlock)stopBlock;

/**
 启动定时器, 秒级, 有超时, 加计数
 */
- (XGCDTimer)startTimerSecIncreaseWithTimeout:(XTimeInteger)timeout perTime:(XTimeInteger)perTime begin:(TimerBeginBlock)beginBlock progress:(TimerProgressBlock)progressBlock finished:(TimerFinishedBlock)finishedBlock stop:(TimerStopBlock)stopBlock;

/**
 启动定时器, 秒级, 有超时, 减计数
 */
- (XGCDTimer)startTimerSecDecreaseWithTimeout:(XTimeInteger)timeout perTime:(XTimeInteger)perTime begin:(TimerBeginBlock)beginBlock progress:(TimerProgressBlock)progressBlock finished:(TimerFinishedBlock)finishedBlock stop:(TimerStopBlock)stopBlock;

/**
 启动定时器, 毫秒级, 无超时, 加计数
 */
- (XGCDTimer)startTimerMSecWithPerTime:(XTimeInteger)perTime begin:(TimerBeginBlock)beginBlock progress:(TimerProgressBlock)progressBlock finished:(TimerFinishedBlock)finishedBlock stop:(TimerStopBlock)stopBlock;

/**
 启动定时器, 秒级, 无超时, 加计数
 */
- (XGCDTimer)startTimerSecWithPerTime:(XTimeInteger)perTime begin:(TimerBeginBlock)beginBlock progress:(TimerProgressBlock)progressBlock finished:(TimerFinishedBlock)finishedBlock stop:(TimerStopBlock)stopBlock;

/**
 启动定时器
 */
- (XGCDTimer)startTimerWithTimeType:(XTimeType)timeType timeDirection:(XTimeDirection)timeDirection timeout:(XTimeInteger)timeout perTime:(XTimeInteger)perTime begin:(TimerBeginBlock)beginBlock progress:(TimerProgressBlock)progressBlock finished:(TimerFinishedBlock)finishedBlock stop:(TimerStopBlock)stopBlock;

/**
 停止定时器
 */
- (void)stopTimer:(XGCDTimer)currentTimer;

- (void)stopTimer;

@end
