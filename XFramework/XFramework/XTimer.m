//
//  XTimer.m
//  XFramework
//
//  Created by XJY on 15-7-26.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import "XTimer.h"

@interface XTimer() {
    __block XTimeInteger    currentTime;
    XGCDTimer               gcdTimer;
    
    TimerBeginBlock     timerBeginBlock;
    TimerProgressBlock  timerProgressBlock;
    TimerFinishedBlock  timerFinishedBlock;
    TimerStopBlock      timerStopBlock;
}

@end

@implementation XTimer

- (XGCDTimer)startTimerMSecIncreaseWithTimeout:(XTimeInteger)timeout perTime:(XTimeInteger)perTime begin:(TimerBeginBlock)beginBlock progress:(TimerProgressBlock)progressBlock finished:(TimerFinishedBlock)finishedBlock stop:(TimerStopBlock)stopBlock {
    
    return [self startTimerWithTimeType:XTimeTypeMSec timeDirection:XTimeDirectionIncrease timeout:timeout perTime:perTime begin:beginBlock progress:progressBlock finished:finishedBlock stop:stopBlock];
    
}

- (XGCDTimer)startTimerMSecDecreaseWithTimeout:(XTimeInteger)timeout perTime:(XTimeInteger)perTime begin:(TimerBeginBlock)beginBlock progress:(TimerProgressBlock)progressBlock finished:(TimerFinishedBlock)finishedBlock stop:(TimerStopBlock)stopBlock {
    
    return [self startTimerWithTimeType:XTimeTypeMSec timeDirection:XTimeDirectionDecrease timeout:timeout perTime:perTime begin:beginBlock progress:progressBlock finished:finishedBlock stop:stopBlock];
    
}

- (XGCDTimer)startTimerSecIncreaseWithTimeout:(XTimeInteger)timeout perTime:(XTimeInteger)perTime begin:(TimerBeginBlock)beginBlock progress:(TimerProgressBlock)progressBlock finished:(TimerFinishedBlock)finishedBlock stop:(TimerStopBlock)stopBlock {
    
    return [self startTimerWithTimeType:XTimeTypeSec timeDirection:XTimeDirectionIncrease timeout:timeout perTime:perTime begin:beginBlock progress:progressBlock finished:finishedBlock stop:stopBlock];
    
}

- (XGCDTimer)startTimerSecDecreaseWithTimeout:(XTimeInteger)timeout perTime:(XTimeInteger)perTime begin:(TimerBeginBlock)beginBlock progress:(TimerProgressBlock)progressBlock finished:(TimerFinishedBlock)finishedBlock stop:(TimerStopBlock)stopBlock {
    
    return [self startTimerWithTimeType:XTimeTypeSec timeDirection:XTimeDirectionDecrease timeout:timeout perTime:perTime begin:beginBlock progress:progressBlock finished:finishedBlock stop:stopBlock];
    
}

- (XGCDTimer)startTimerMSecWithPerTime:(XTimeInteger)perTime begin:(TimerBeginBlock)beginBlock progress:(TimerProgressBlock)progressBlock finished:(TimerFinishedBlock)finishedBlock stop:(TimerStopBlock)stopBlock {
    
    return [self startTimerMSecIncreaseWithTimeout:0 perTime:perTime begin:beginBlock progress:progressBlock finished:finishedBlock stop:stopBlock];
    
}

- (XGCDTimer)startTimerSecWithPerTime:(XTimeInteger)perTime begin:(TimerBeginBlock)beginBlock progress:(TimerProgressBlock)progressBlock finished:(TimerFinishedBlock)finishedBlock stop:(TimerStopBlock)stopBlock {
    
    return [self startTimerSecIncreaseWithTimeout:0 perTime:perTime begin:beginBlock progress:progressBlock finished:finishedBlock stop:stopBlock];
    
}

- (XGCDTimer)startTimerWithTimeType:(XTimeType)timeType timeDirection:(XTimeDirection)timeDirection timeout:(XTimeInteger)timeout perTime:(XTimeInteger)perTime begin:(TimerBeginBlock)beginBlock progress:(TimerProgressBlock)progressBlock finished:(TimerFinishedBlock)finishedBlock stop:(TimerStopBlock)stopBlock {
    
    timerBeginBlock = beginBlock;
    timerProgressBlock = progressBlock;
    timerFinishedBlock = finishedBlock;
    timerStopBlock = stopBlock;
    
    BOOL hasTimeout = NO;
    if (timeout <= 0) {
        hasTimeout = NO;
        currentTime = 0;
        timeDirection = XTimeDirectionIncrease;
    } else {
        hasTimeout = YES;
        if (timeDirection == XTimeDirectionDecrease) {
            currentTime = timeout;
        } else {
            currentTime = 0;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (timerBeginBlock) {
            timerBeginBlock(currentTime);
        }
    });
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),perTime*timeType, 0);
    dispatch_source_set_event_handler(_timer, ^{
        
        if (hasTimeout == YES &&
            ((timeDirection == XTimeDirectionDecrease && currentTime <= 0) || (timeDirection == XTimeDirectionIncrease && currentTime >= timeout))
            ) {
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (timerProgressBlock) {
                    timerProgressBlock(currentTime);
                }
                if (timerFinishedBlock) {
                    timerFinishedBlock(currentTime);
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (timerProgressBlock) {
                    timerProgressBlock(currentTime);
                }
                if (timeDirection == XTimeDirectionDecrease) {
                    currentTime -= perTime;
                } else {
                    currentTime += perTime;
                }
            });
        }
    });
    dispatch_resume(_timer);
    gcdTimer = _timer;
    
    return _timer;
}

- (void)stopTimer:(XGCDTimer)currentTimer {
    if (currentTimer == nil) {
        return;
    }
    dispatch_source_cancel(currentTimer);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (timerStopBlock) {
            timerStopBlock(currentTime);
        }
    });
}

- (void)stopTimer {
    [self stopTimer:gcdTimer];
}

@end
