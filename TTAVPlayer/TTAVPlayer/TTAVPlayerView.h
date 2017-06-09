//
//  TTAVPlayerView.h
//  Multimedia
//
//  Created by dylan.tang on 17/1/30.
//  Copyright © 2017年 dylan.tang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "TTAVPlayerVideoInfo.h"


@class TTAVPlayerView;

typedef NS_ENUM(NSUInteger,TTAVPlayerViewMode){
    TTAVPlayerViewNormalMode = 0,  //正常模式
    TTAVPlayerViewPortraitMode = 1,  //竖屏模式
    TTAVPlayerViewLandScapeMode = 2, //横屏模式
    TTAVPlayerViewMuteMode = 3, //静音自动播放模式
    TTAVPlayerViewUserDefineMode = 4 //自定义模式
};

typedef NS_ENUM(NSInteger, TTAVPlayerViewNetworkStatus) {
    TTAVPlayerViewNetworkStatusUnknown = 0,
    TTAVPlayerViewNetworkStatusNotReachable,
    TTAVPlayerViewNetworkStatusWiFi,
    TTAVPlayerViewNetworkStatusWWAN
};

@protocol TTAVPlayerViewDelegate <NSObject>

@optional

// Touch Action

- (void)videoViewDidGetTap;

- (void)closeButtonGetTap;

// Video LifeCycle

- (void)videoUIDidLoad;

- (void)videoDidPrepared;

- (void)videoDidEndPlay:(TTAVPlayerView*)playerView;

- (void)videoDidPlay;

- (void)videoDidPause;

- (void)onVideoNormalScreen;

- (void)onVideoFullScreen;

//等待数据，数据缓冲回调
- (void)onVideoWaitingData;

//网络状态差，需要等待
- (void)onVideoStalled;

//数据准备完毕
- (void)onVideoDataReady;

//视频播放出错回调
- (void)onVideoPlayError:(NSError*)error;

//播放进度更新
- (void)onVideoProcessUpdate:(CMTime)current duration:(CMTime)duration;

//加载进度更新
-(void)onVideoLoadingProcess:(Float64)seconds;

@end

@interface TTAVPlayerView : UIView

@property (nonatomic,weak) id<TTAVPlayerViewDelegate> delegate;

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame withViewMode:(TTAVPlayerViewMode)mode;

- (instancetype)initWithFrame:(CGRect)frame withVideoInfo:(TTAVPlayerVideoInfo*)videoInfo withViewMode:(TTAVPlayerViewMode)mode;

#pragma mark - 播放器基础控制方法

- (void)play;

- (void)pause;

- (void)seekToTime:(CMTime)time completionHandler:(void (^)(BOOL finished))completionHandler;

- (void)replay;

- (void)stop;

#pragma mark - PlayerView控制方法

- (void)toggleFullScreen;

#pragma mark - status && Flag

@property (nonatomic, assign) TTAVPlayerViewNetworkStatus networkStatus;

@property (nonatomic, assign) TTAVPlayerViewNetworkStatus lastNetworkStatus;

@property (nonatomic, readonly) BOOL isPlaying;

@property (nonatomic, assign) BOOL isFullScreen;

@property (nonatomic, copy) void(^networkHandler)(TTAVPlayerViewNetworkStatus status);

#pragma mark - Props

@property (nonatomic, strong) NSString *videoUrl;

@property (nonatomic, strong) NSString *videoTitle;

@property (nonatomic, strong) TTAVPlayerVideoInfo *videoInfo;

@end
