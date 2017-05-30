//
//  TTMultiMediaAVPlayer.h
//  Multimedia
//
//  Created by 凡铁 on 17/2/6.
//  Copyright © 2017年 Alipay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "TTReachability.h"

typedef NS_ENUM(NSInteger, TTAVPlayerNetworkStatus) {
    TTAVPlayerNetworkStatusUnknown = 0,
    TTAVPlayerNetworkStatusNotReachable,
    TTAVPlayerNetworkStatusWiFi,
    TTAVPlayerNetworkStatusWWAN
};
typedef NS_ENUM (NSInteger, TTMultiMediaAVPlayerStatus) {
    TTMultiMediaAVPlayerStatusUnknown = 0,
    TTMultiMediaAVPlayerStatusReady,
    TTMultiMediaAVPlayerStatusWaiting,
    TTMultiMediaAVPlayerStatusPlaying,
    TTMultiMediaAVPlayerStatusError
};
typedef NS_ENUM(NSInteger,TTMultiMediaAVPlayerError) {
    TTMultiMediaAVPlayerErrorNoNetwork = 0,//无网络
    TTMultiMediaAVPlayerErrorStalled,//异常中断
};

@protocol TTMultiMediaAVPlayerDelegate <NSObject>
@optional
-(void)playerProcess:(CMTime)current duration:(CMTime)duration;//更新播放进度
-(void)playerError:(NSError*)error;//播放失败
-(void)playerFinished;//播放完成
-(void)playerStalled:(AVPlayerItemStatus)status;//异常中断
-(void)loadingProcess:(Float64)seconds;//已经加载进度
-(void)playerWaiting;//等待数据
-(void)playerReady;//数据到了
-(void)playerCanPlay;//item初始化成功，可以播放
@end

@interface TTMultiMediaAVPlayer : AVPlayer
@property (nonatomic, readonly) BOOL isLoadingFromCache;
@property (nonatomic, assign) TTAVPlayerNetworkStatus networkStatus;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) CGFloat duration;
@property (nonatomic, assign) CGFloat cacheProgress;
@property (nonatomic, readonly) BOOL isPlaying;
@property (nonatomic, weak) id<TTMultiMediaAVPlayerDelegate> delegate;
@property (nonatomic, readonly) Float64 loadedTime;
- (void)reloadWithURL:(NSURL *)url completionHandler:(void (^)(NSError *error))handler;

+ (void)playerWithURL:(NSURL *)URL completionHandler:(void (^)(TTMultiMediaAVPlayer *player, NSError *error))handler;
@end
