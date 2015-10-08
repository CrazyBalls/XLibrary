//
//  XReachabilityManager.m
//  XFramework
//
//  Created by XJY on 15-7-29.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import "XReachabilityManager.h"

@interface XReachabilityManager() {
    Reachability *internetReachability;
    
    NetworkStatusChangedBlock networkStatusChangedBlock;
}

@end

@implementation XReachabilityManager

+ (instancetype)sharedManager {
    static XReachabilityManager *manager;
    if (manager == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            manager = [[self alloc] init];
        });
    }
    return manager;
}

- (void)startNotifier {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    internetReachability = [Reachability reachabilityForInternetConnection];
    [internetReachability startNotifier];
    [self updateInterfaceWithReachability:internetReachability];
}

- (void)startNotifier:(NetworkStatusChangedBlock)block {
    networkStatusChangedBlock = block;
    [self startNotifier];
}

- (void)stopNotifier {
    networkStatusChangedBlock = nil;
    if (internetReachability == nil) {
        return;
    }
    [internetReachability stopNotifier];
    internetReachability = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

/*!
 * Called by Reachability whenever status changes.
 */
- (void)reachabilityChanged:(NSNotification *)note {
    Reachability* curReach = [note object];
    [self updateInterfaceWithReachability:curReach];
}

- (void)updateInterfaceWithReachability:(Reachability *)reachability {
    if (internetReachability == nil) {
        return;
    }
    if (reachability != internetReachability) {
        return;
    }
    
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    if (networkStatusChangedBlock != nil) {
        networkStatusChangedBlock(netStatus);
    }
    if(_delegate != nil && [_delegate respondsToSelector:@selector(networkStatusChanged:)]) {
        [_delegate networkStatusChanged:netStatus];
    }
}

- (void)updateInterfaceWithReachability {
    if (internetReachability == nil) {
        return;
    }
    [self updateInterfaceWithReachability:internetReachability];
}

- (NetworkStatus)getNetworkStatus {
    if (internetReachability == nil) {
        return NotReachable;
    }
    NetworkStatus netStatus = [internetReachability currentReachabilityStatus];
    return netStatus;
}

- (BOOL)getHasNetWork {
    NetworkStatus netStatus = [self getNetworkStatus];

    if (netStatus == NotReachable) {
        return NO;
    } else if (netStatus == ReachableViaWWAN) {
        return YES;
    } else if (netStatus == ReachableViaWiFi) {
        return YES;
    } else {
        return NO;
    }
}

@end
