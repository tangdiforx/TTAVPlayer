//
//  TTAVPlayerView_Private.h
//  Multimedia
//
//  Created by 凡铁 on 17/2/7.
//  Copyright © 2017年 Alipay. All rights reserved.
//

#import "TTAVPlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "TTMultiMediaAVPlayer.h"
#import "TTAVPlayerSwipeHandlerView.h"
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>

@interface TTAVPlayerView ()

@property (nonatomic, strong) TTMultiMediaAVPlayer *player;

@property (strong, nonatomic) AVPlayerItem *currentItem;

@property (nonatomic, assign) TTMultiMediaAVPlayerStatus playerStatus;

@property (nonatomic, assign) Float64 loadedTime;

@property (nonatomic, assign) Float64 totalTime;

@property (nonatomic, assign) TTAVPlayerViewMode viewMode;

@property (nonatomic, assign) TTAVPlayerViewMode originViewMode;

@property (nonatomic,strong) MPVolumeView *volumeView;

@property (nonatomic, strong) CTCallCenter *callCenter;

@property (nonatomic, assign) BOOL isDragingSlider;

@property (nonatomic, assign) BOOL isHideControlViews;//是否隐藏ControlView

@property (nonatomic, assign) BOOL isAllowNoWIFIPlay;//是否允许非WIFI条件下播放

//用于全屏变换之后的还原
@property (nonatomic,assign) CGRect originFrame;

@property (nonatomic,assign) CGRect originMuteFrame;

@property (nonatomic, weak) UIView *mySuperView;

@property (nonatomic, assign) BOOL isShowControlViewAnimated;

@property (nonatomic, assign) BOOL isCloseAnimation;

#pragma mark - UI

//视频层
@property (nonatomic,strong) TTAVPlayerInternalView *videoView;

@property (nonatomic,strong) TTAVPlayerErrorView *errorView;

@property (nonatomic,strong) TTAVPlayerInfoChangeView *infoChangeView;//音量，亮度，全屏时有效.自定义模式下，仍支持音量的View显示，以防出bug

// All Mode

@property (nonatomic,strong) UIView *headControlView;

@property (nonatomic,strong) UIView *bottomControlView;

@property (nonatomic,strong) UIButton *playBtn;

@property (nonatomic,strong) TTAVPlayerSlider *slider;

@property (nonatomic,strong) UIButton *fullScreenBtn;

@property (nonatomic,strong) TTAVPlayerTimeLabel *currentTimeLabel;

@property (nonatomic,strong) TTAVPlayerTimeLabel *totalTimeLabel;

@property (nonatomic,strong) TTAVPlayerLoadingView *loadingView;

// PortraitMode + NormalMode

@property (nonatomic,strong) UIButton *closeBtn;

// landScapeMode

@property (nonatomic,strong) UIButton *backBtn;

@property (nonatomic,strong) UILabel *titleLabel;

@property (nonatomic,strong) TTAVPlayerSwipeHandlerView *handleSwipeView;//全屏模式下，处理滑动屏幕的View

@end
