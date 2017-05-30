//
//  TTAVPlayerView+Observer.h
//  Multimedia
//
//  Created by 凡铁 on 17/2/7.
//  Copyright © 2017年 Alipay. All rights reserved.
//

#import "TTAVPlayerView.h"

@interface TTAVPlayerView (Observer)

- (void)setupNotificationObserver;
- (void)setupPlayerObserver;
- (void)cleanPlayerObserver;
- (void)clean;

/**
 *  手动触发检测网络状态
 */
- (void)checkNetworkStatus;

@end
