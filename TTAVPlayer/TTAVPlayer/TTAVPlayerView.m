//
//  TTAVPlayerView.m
//  Multimedia
//
//  Created by dylan.tang on 17/1/30.
//  Copyright © 2017年 dylan.tang. All rights reserved.
//

#import "TTAVPlayerView.h"
#import "TTAVPlayerView+ViewMode.h"
#import "TTMultiMediaAVPlayer.h"
#import "TTAVPlayerView_Private.h"
#import "TTAVPlayerView+Observer.h"
#import "TTAVPlayerView+Event.h"

@interface TTAVPlayerView()<TTMultiMediaAVPlayerDelegate,UIAlertViewDelegate>

//在播放缓存视频的时候，对网络状态变更的处理不一样
@property (nonatomic,assign) BOOL videoFromLocal;

@end

@implementation TTAVPlayerView

- (instancetype)initWithFrame:(CGRect)frame withViewMode:(TTAVPlayerViewMode)mode{
    self = [super initWithFrame:frame];
    if (self){
        [self setupUIWithViewMode:mode];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame withVideoInfo:(TTAVPlayerVideoInfo *)videoInfo withViewMode:(TTAVPlayerViewMode)mode{
    self = [super initWithFrame:frame];
    if (self){
        self.videoInfo = videoInfo;
        self.viewMode = mode;
        [self initParams];
        [self setupUIWithViewMode:mode];
    }
    return self;
}

- (void)dealloc{
    [self clean];
}

#pragma mark - init

- (void)initParams{
    self.videoUrl = self.videoInfo.videoUrl;
    self.videoTitle = self.videoInfo.videoTitle;
}

- (void)setup{
    [self initParams];
}

#pragma mark - network

- (void)showNOWifiAlert{
    if (self.isAllowNoWIFIPlay){
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(noWIFIAlertShow) object:nil];
    [self performSelector:@selector(noWIFIAlertShow) withObject:nil afterDelay:1.0f];
}

- (void)noWIFIAlertShow{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"当前网络非WIFI，是否确定继续播放" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        if (self.player){
//            [self makeToast:@"已为您自动暂停" completion:^(BOOL finished) {
//            
//            }];
        }else{
            [self clickCloseBtn];
        }
    }else{
        self.isAllowNoWIFIPlay = YES;
        if (self.errorView.isHidden){
            [self play];
        }
    }
}

- (void)setupNetworkStatusHandler
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.networkHandler = ^(TTAVPlayerViewNetworkStatus status) {
            switch (status) {
                case TTAVPlayerViewNetworkStatusNotReachable:
                {
                    [weakSelf hideLoadingIndicator];
                    if (weakSelf.videoFromLocal) {
                        // 有缓存
                        [weakSelf hideErrorView];
                    } else {
                        // 无缓存
//                        [weakSelf makeToast:@"已失去网络连接"];
                    }
                    weakSelf.lastNetworkStatus = status;
                    break;
                }
                case TTAVPlayerViewNetworkStatusWiFi:
                {
                    weakSelf.lastNetworkStatus = status;
                    break;
                }
                case TTAVPlayerViewNetworkStatusWWAN:
                {
                    if (weakSelf.isPlaying){
                        [weakSelf pause];
                    }
                    if (weakSelf.lastNetworkStatus == TTAVPlayerViewNetworkStatusWiFi && weakSelf.viewMode != TTAVPlayerViewLandScapeMode){
                        [weakSelf showNOWifiAlert];
                    }else if (weakSelf.lastNetworkStatus == TTAVPlayerViewNetworkStatusWiFi && weakSelf.viewMode == TTAVPlayerViewLandScapeMode){
                        if (!weakSelf.isAllowNoWIFIPlay){
                            [weakSelf pause];
//                            [weakSelf makeToast:@"当前网络非WIFI，已为您自动暂停" completion:^(BOOL finished) {
//                                
//                            }];
                        }
                    }
                    weakSelf.lastNetworkStatus = status;
                    break;
                }
                default:
                    break;
            }
        };
    });
}

#pragma mark - 播放器控制

- (void)play{
    [self checkNetworkStatus];
    if ([self isShowNOWifiAlert]){
        [self showNOWifiAlert];
        return;
    }
    [self hideErrorView];
    [self showLoadingIndicator];
    
    if (STRING_IS_BLANK(self.videoUrl)){
        return;
    }
    
    if (!self.player){
        [self loadPlayer];
        return;
    }
    
    [self playViewDidPlayWithPreload:NO];
}

- (BOOL)isShowNOWifiAlert{
    if (self.networkStatus == TTAVPlayerNetworkStatusWWAN && !self.isAllowNoWIFIPlay && self.viewMode != TTAVPlayerViewLandScapeMode){
        return YES;
    }
    return false;
}

- (void)pause{
    [self.playBtn setSelected:YES];
    [self.player pause];
    _isPlaying = NO;
}

- (void)stop{
    [self.playBtn setSelected:YES];
    _isPlaying = NO;
    [self.player pause];
}

- (void)replay{
    [self play];
}

- (void)seekToTime:(CMTime)time completionHandler:(void(^)(BOOL))completionHandler{
    //    [self.player seekToTime:time];这种方法会有误差，详见官方文档:The time seeked to may differ from the specified time for efficiency. For sample accurate seeking see seekToTime:toleranceBefore:toleranceAfter
    [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:completionHandler];
    
}

- (void)toggleFullScreen{
    __weak typeof (self) weakSelf = self;
    if (!_isFullScreen){
        self.originFrame = self.frame;
        //为了防止被NavBar,TabBar之类的挡住，播放器需要add在window上
        if (![[UIApplication sharedApplication].keyWindow.subviews containsObject:weakSelf]){
            self.mySuperView = self.superview;
            [[UIApplication sharedApplication].keyWindow addSubview:weakSelf];
        }
        [UIView animateWithDuration:0.2 animations:^{
            self.transform = CGAffineTransformMakeRotation(M_PI/2);
            self.frame = CGRectMake(0, 0 , [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            self.videoView.frame = self.bounds;
            if (self.viewMode != TTAVPlayerViewUserDefineMode){
                [self changeToLandScapeMode];
            }
            
        } completion:^(BOOL finished) {
            self.isFullScreen = YES;
        }];
        
    }else{
        if ([[UIApplication sharedApplication].keyWindow.subviews containsObject:weakSelf]){
            //如果播放器本来就在KeyWindow上，那么mySuperview为空，则不会影响到自己的superview
            [self.mySuperView addSubview:weakSelf];
        }
        [UIView animateWithDuration:0.2 animations:^{
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
            self.transform = CGAffineTransformIdentity;
            self.frame = self.originFrame;
            if (self.viewMode != TTAVPlayerViewUserDefineMode){
                [self backToOriginViewMode];
                if ([self.delegate respondsToSelector:@selector(onVideoNormalScreen)]){
                    [self.delegate onVideoNormalScreen];
                }
            }
        } completion:^(BOOL finished) {
            self.isFullScreen = NO;
        }];
    }
}

- (void)loadPlayer{
    if (self.player || !self.videoUrl){
        return;
    }
    [self beforePlayerLoadPretreatment];
    __weak typeof(self) weakSelf = self;
    [TTMultiMediaAVPlayer playerWithURL:[NSURL URLWithString:self.videoUrl] completionHandler:^(TTMultiMediaAVPlayer *player, NSError *error) {
        if (error){
            [weakSelf showErrorViewWithTitle:error.localizedDescription];
            return ;
        }
        
        weakSelf.player = player;
        weakSelf.player.delegate = weakSelf;
        weakSelf.currentItem = weakSelf.player.currentItem;
        weakSelf.totalTime = weakSelf.currentItem.asset.duration.value / weakSelf.currentItem.asset.duration.timescale;
        
        [weakSelf setupNotificationObserver];
        [weakSelf setupPlayerObserver];
        [weakSelf setupNetworkStatusHandler];
    }];
}

- (void)playViewDidPlayWithPreload:(BOOL)preload
{
    [self hideLoadingIndicator];
    if (!self.player) {
        return;
    }
    
    if (preload) {
        [(AVPlayerLayer *) self.videoView.layer setPlayer:self.player];
        [self.player setAllowsExternalPlayback:YES];
        CMTime seek = kCMTimeZero;
        if (self.currentItem.error) {
            seek = self.player.currentTime;
            [self cleanPlayerObserver];
        }
        if (CMTIME_IS_VALID(seek)) {
            [self.player seekToTime:seek toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        }
    }
    
    _isPlaying = YES;
    [self.playBtn setSelected:NO];
    [self.player play];
    [self toggleAutoHideOperationView];
}

- (void)hideErrorView{
    self.errorView.hidden  = YES;
}

- (void)showErrorViewWithTitle:(NSString*)title{
    [self hideLoadingIndicator];
    [self hideControlViewAniamted:NO];
    title = STRING_IS_BLANK(title)?@"视频播放出错":title;
    [self.errorView setTitle:title];
    self.errorView.hidden = NO;
}

- (void)showLoadingIndicator{
    self.loadingView.hidden = NO;
}

- (void)hideLoadingIndicator{
    self.loadingView.hidden = YES;
}

//播放器加载完毕前的预处理
- (void)beforePlayerLoadPretreatment{
    self.slider.userInteractionEnabled = NO;
}

//播放器加载完毕之后的处理,这部分逻辑不与播放方法耦合
- (void)afterPlayerLoadTreatment{
    self.slider.userInteractionEnabled = YES;
}

#pragma mark - player delegate

//更新播放进度
- (void)playerProcess:(CMTime)current duration:(CMTime)duration{
    
    if ([self.delegate respondsToSelector:@selector(onVideoProcessUpdate:duration:)]){
        [self.delegate onVideoProcessUpdate:current duration:duration];
    }
    
    if (self.viewMode == TTAVPlayerViewUserDefineMode){
        return;
    }
    
    [self refreshProgressSlider];
}

//播放失败
- (void)playerError:(NSError*)error{
    if ([self.delegate respondsToSelector:@selector(onVideoPlayError:)]){
        [self.delegate onVideoPlayError:error];
    }
    
    if (self.viewMode == TTAVPlayerViewUserDefineMode){
        return;
    }

    [self showErrorViewWithTitle:error.localizedDescription];
}

//播放完成
- (void)playerFinished{
    [self hideErrorView];
    __weak typeof(self) weakSelf = self;
    [self.player seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf stop];
            if ([weakSelf.delegate respondsToSelector:@selector(videoDidEndPlay:)]) {
                [weakSelf.delegate videoDidEndPlay:weakSelf];
            }
        });
    }];
}

//异常中断
- (void)playerStalled:(AVPlayerItemStatus)status{
    if ([self.delegate respondsToSelector:@selector(onVideoStalled)]){
        [self.delegate onVideoStalled];
    }
    
    if (self.viewMode == TTAVPlayerViewUserDefineMode){
        return;
    }
    
    [self showLoadingIndicator];
}

//已经加载进度
- (void)loadingProcess:(Float64)seconds{
    if ([self.delegate respondsToSelector:@selector(onVideoLoadingProcess:)]){
        [self.delegate onVideoLoadingProcess:seconds];
    }
    
    if (self.viewMode == TTAVPlayerViewUserDefineMode){
        return;
    }
    float value = seconds / self.totalTime;
    [self.slider refreshLoadingProgress:value];
}

//等待数据
- (void)playerWaiting{
    if ([self.delegate respondsToSelector:@selector(onVideoWaitingData)]){
        [self.delegate onVideoWaitingData];
    }
    
    if (self.viewMode == TTAVPlayerViewUserDefineMode){
        return;
    }
    
    [self hideErrorView];
    [self showLoadingIndicator];
}

//数据到了
- (void)playerReady{
    if ([self.delegate respondsToSelector:@selector(onVideoDataReady)]){
        [self.delegate onVideoDataReady];
    }
    if (self.viewMode == TTAVPlayerViewUserDefineMode){
        return;
    }

    [self hideErrorView];
    [self hideLoadingIndicator];
}

//item初始化成功，可以播放
- (void)playerCanPlay{
    [self playViewDidPlayWithPreload:YES];
    [self afterPlayerLoadTreatment];
}

@end
