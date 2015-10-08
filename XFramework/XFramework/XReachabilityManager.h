//
//  XReachabilityManager.h
//  XFramework
//
//  Created by XJY on 15-7-29.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@protocol XReachabilityManagerDelegate <NSObject>

@optional
/**
 网络状态改变时调用
 */
- (void)networkStatusChanged:(NetworkStatus)netStatus;

@end

@interface XReachabilityManager : NSObject

typedef void (^NetworkStatusChangedBlock)(NetworkStatus netStatus);

@property (nonatomic, assign) id <XReachabilityManagerDelegate> delegate;

@property (nonatomic, assign, getter=getNetworkStatus)  NetworkStatus   networkStatus;

@property (nonatomic, assign, getter=getHasNetWork)     BOOL            hasNetWork;

/**
 单例
 */
+ (instancetype)sharedManager;

/**
 开启网络检测
 */
- (void)startNotifier;

- (void)startNotifier:(NetworkStatusChangedBlock)block;

/**
 关闭网络检测
 */
- (void)stopNotifier;

/**
 更新网络状态
 */
- (void)updateInterfaceWithReachability;

@end
