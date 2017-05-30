//
//  TTMultiMediaAVPlayer+Observer.m
//  Multimedia
//
//  Created by 张祖权 on 2017/2/10.
//  Copyright © 2017年 Alipay. All rights reserved.
//

#import "TTMultiMediaAVPlayer+Observer.h"
#import <MediaPlayer/MediaPlayer.h>
#import "TTReachability.h"
#import "TTMultiMediaAVPlayer_Private.h"

@implementation TTMultiMediaAVPlayer (Observer)

/**
 *  播放状态监听
 */
- (void)setupPlayerObserver {
    NSNotificationCenter *ntf = [NSNotificationCenter defaultCenter];
    [ntf addObserver:self
            selector:@selector(playerDidFinishPlaying:)
                name:AVPlayerItemDidPlayToEndTimeNotification
              object:self.currentItem];
    [ntf addObserver:self
            selector:@selector(playerFailedToPlayToEnd:)
                name:AVPlayerItemFailedToPlayToEndTimeNotification
              object:self.currentItem];
    [ntf addObserver:self
            selector:@selector(playerStalled:)
                name:AVPlayerItemPlaybackStalledNotification
              object:self.currentItem];//添加视频异常中断通知
    
    [self.currentItem addObserver:self
                       forKeyPath:@"status"
                          options:NSKeyValueObservingOptionInitial
                          context:nil];
    
    [self.currentItem addObserver:self
                       forKeyPath:@"loadedTimeRanges"
                          options:NSKeyValueObservingOptionNew
                          context:NULL];
    
    [self addObserver:self
                  forKeyPath:@"rate"
                     options:0
                     context:nil];
    [self.currentItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [self.currentItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    __weak typeof(self) weakSelf = self;
    
    self.timeObserver = [self addPeriodicTimeObserverForInterval:CMTimeMake(1, 10)
                                                                  queue:dispatch_get_main_queue()
                                                             usingBlock:^(CMTime time) {
                                                                 [weakSelf refreshProgress];                                                         }];
}

- (void)cleanPlayerObserver {
    NSNotificationCenter *ntf = [NSNotificationCenter defaultCenter];
    [ntf removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.currentItem];
    [ntf removeObserver:self name:AVPlayerItemFailedToPlayToEndTimeNotification object:self.currentItem];
    [ntf removeObserver:self name:AVPlayerItemPlaybackStalledNotification object:self.currentItem];
    @try {
        if (self.currentItem) {
            
            [self.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
            [self.currentItem removeObserver:self forKeyPath:@"status"];
            [self.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
            [self.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
            
        }
        [self removeObserver:self forKeyPath:@"rate"];
        [self removeTimeObserver:self.timeObserver];
    } @catch (NSException *exception) {
    }
}



- (void)clean {
    [self setAllowsExternalPlayback:NO];
    //    self.playerInited = NO;
    [self cleanPlayerObserver];
}


/**
 *  播放进度回调
 */
- (void)refreshProgress {
    CMTime duration = self.currentItem.duration;
    CMTime process = self.currentItem.currentTime;
    __weak typeof (self) weakSelf   = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(playerProcess:duration:)]) {
            [weakSelf.delegate playerProcess:process duration:duration];
        }
    });
}

/**
 *  播放错误
 */
-(void)playerFailedToPlayToEnd:(NSNotification *)notification {
    NSError *error  = notification.userInfo[AVPlayerItemFailedToPlayToEndTimeErrorKey];
    [self playerError:error];
}

/**
 * 播放完成
 */
-(void)playerDidFinishPlaying:(NSNotification *)notification {
    __weak typeof (self) weakSelf   = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(playerFinished)]) {
            [weakSelf.delegate playerFinished];
        }
    });
}

/**
 * 异常中断
 */
-(void)playerStalled:(NSNotification *)notification {
    self.playerStatus   = TTMultiMediaAVPlayerStatusWaiting;
    //[self pause];
    __weak typeof (self) weakSelf   = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(playerStalled:)]) {
            [weakSelf.delegate playerStalled:self.currentItem.status];
        }
    });
    /*
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"播放异常"                                                                      forKey:NSLocalizedDescriptionKey];
    NSError *aError = [NSError errorWithDomain:@"fliggy.com" code:TTMultiMediaAVPlayerErrorStalled userInfo:userInfo];
    [self playerError:aError];
     */
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        switch (self.currentItem.status) {
            case AVPlayerItemStatusUnknown:
                self.playerStatus   = TTMultiMediaAVPlayerStatusUnknown;
                break;
            case AVPlayerItemStatusReadyToPlay:
                //__weak typeof(self) weakSelf = self;
                [self playerCanPlay];
                if (self.rate > 0) {
                    self.playerStatus   = TTMultiMediaAVPlayerStatusPlaying;
                } else if (self.rate == 0) {
                    self.playerStatus   = TTMultiMediaAVPlayerStatusReady;
                } else {
                    self.playerStatus   = TTMultiMediaAVPlayerStatusError;
                }
                if (self.playerStatus != TTMultiMediaAVPlayerStatusError) {
                    [self playerReady];
                }
                break;
            case AVPlayerItemStatusFailed:
                self.playerStatus   = TTMultiMediaAVPlayerStatusError;
                [self playerError:self.currentItem.error];
                break;
        }
    } else if ([keyPath isEqualToString:@"rate"]) {
        NSLog(@"observeValueForKeyPath:rate:%f",self.rate);
        if (self.playerStatus == TTMultiMediaAVPlayerStatusError || self.playerStatus == TTMultiMediaAVPlayerStatusUnknown) {
            return;
        }
        if (self.isPlaying) {//当前用户点击了播放
            CGFloat rate    = self.rate;
            if (rate == 0) {//播放器处于暂停状态
                self.playerStatus   = TTMultiMediaAVPlayerStatusReady;
                [self playerReady];
            } else if (rate > 0) {//播放器处于播放状态
                //self.playerStatus   = TTMultiMediaAVPlayerStatusPlaying;
                if ([self checkAvailable]) {
                    [self playerReady];
                } else {
                    Reachability *reach = [Reachability reachabilityForInternetConnection];
                    if ([reach currentReachabilityStatus] == TTAVPlayerNotReachable) {
                        self.playerStatus   = TTMultiMediaAVPlayerStatusError;
                        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"您的网络不可用，请稍后再尝试"                                                                      forKey:NSLocalizedDescriptionKey];
                        NSError *aError = [NSError errorWithDomain:@"fliggy.com" code:TTMultiMediaAVPlayerErrorNoNetwork userInfo:userInfo];
                        [self playerError:aError];
                    } else {
                        //self.playerStatus   = TTMultiMediaAVPlayerStatusWaiting;
                        [self statusWaiting];
                    }
                }
            } else if(self.currentItem.error){//播放器播放错误
                self.playerStatus   = TTMultiMediaAVPlayerStatusError;
                [self playerError:self.currentItem.error];
                
            }
        } else {//用户没有点击播放按钮
            
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {//缓冲区发生变化
        [self loadingProcess];
        if (self.isPlaying) {//用户点击了播放
            if ([self checkAvailable]) {//当前有数据
                if (self.playerStatus == TTMultiMediaAVPlayerStatusWaiting) {//播放器处于等待状态
                    self.playerStatus   = TTMultiMediaAVPlayerStatusPlaying;
                    [self play];
                    [self playerReady];
                }
            } else {
                [self statusWaiting];
            }
        }
    } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {//seek之后缓存不足
        if ([self.currentItem isPlaybackBufferEmpty]) {
            [self statusWaiting];
        }
    } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {//seek之后缓存足够
        if ([self.currentItem isPlaybackLikelyToKeepUp]) {
            if (self.isPlaying) {//用户点击了播放
                //if (self.playerStatus != TTMultiMediaAVPlayerStatusPlaying && self.playerStatus != TTMultiMediaAVPlayerStatusReady) {//播放器处于播放状态
                //    if ([self checkAvailable]) {//当前有数据
                        self.playerStatus   = TTMultiMediaAVPlayerStatusPlaying;
                        [self playerReady];
                //        [self play];
                //    }
                //}
            }
        }
        
    }
}
-(void)playerCanPlay {
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(playerCanPlay)]) {
            [weakSelf.delegate playerCanPlay];
        }
    });
}

-(void)playerReady {
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(playerReady)]) {
            [weakSelf.delegate playerReady];
        }
    });
}

-(void)loadingProcess {
    NSArray *loadedTimeRanges = self.currentItem.loadedTimeRanges;
    if ([loadedTimeRanges count] > 0) {
        CMTimeRange timeRange       = [[loadedTimeRanges objectAtIndex:0] CMTimeRangeValue];
        Float64 start   = CMTimeGetSeconds(timeRange.start);
        Float64 duration   = CMTimeGetSeconds(timeRange.duration);
        __weak typeof (self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(loadingProcess:)]) {
                [weakSelf.delegate loadingProcess:(start + duration)];
            }
        });
    }
}

@end
