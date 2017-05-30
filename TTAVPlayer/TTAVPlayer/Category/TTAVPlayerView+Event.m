//
//  TTAVPlayerView+Action.m
//  Multimedia
//
//  Created by 凡铁 on 17/2/7.
//  Copyright © 2017年 Alipay. All rights reserved.
//

#import "TTAVPlayerView+Event.h"
#import "TTAVPlayerView+Observer.h"
#import "TTAVPlayerView_Private.h"
#import "TTAVPlayerView+ViewMode.h"
#import <objc/runtime.h>

@interface TTAVPlayerView()

/** 是否设置过总时间Label标志位，保证只设置一次*/
@property (nonatomic,assign) BOOL isTotalTimeLabelSet;

@property (nonatomic,strong) NSDateFormatter *dateFormatter;

@end

@implementation TTAVPlayerView (Action)

static char dateFormatterAssoKey;
static char timeSetAssoKey;

- (void)clickPlayBtn{
    [self toggleAutoHideOperationView];

    if (![self.playBtn isSelected]){
        [self pause];
    }else{
        [self play];
    }
}

- (void)clickFullScreenBtn{
    [self hideControlViewAniamted:NO];
    [self toggleFullScreen];
}

- (void)clickCloseBtn{
    if (self.viewMode == TTAVPlayerViewNormalMode){
        [self toggleAutoHideOperationView];
        [self stop];
        [self removeFromSuperview];
        [self clean];
        if ([self.delegate respondsToSelector:@selector(closeButtonGetTap)]){
            [self.delegate closeButtonGetTap];
        }
        return;
    }
    
    if (self.viewMode == TTAVPlayerViewPortraitMode){
        [self showTVOffAnimationAndClose];
    }
    
}

- (void)showTVOffAnimationAndClose{
    self.isCloseAnimation = YES;
    [self hideControlViewAniamted:NO];
    ((AVPlayerLayer*)self.videoView.layer).videoGravity = AVLayerVideoGravityResize;
    [UIView animateWithDuration:0.3f animations:^{
        self.videoView.layer.frame = CGRectMake(0.0f, (self.height - 3.0f)/2, [UIScreen mainScreen].bounds.size.width, 3.0f);
    } completion:^(BOOL finished) {
        [self finishAnimationAndClose];
    }];
}

- (void)finishAnimationAndClose{
    [UIView animateWithDuration:0.1f animations:^{
        self.videoView.layer.frame = CGRectMake((self.width - 10.0f)/2, (self.height - 3.0f)/2, 10.0f, 3.0f);
    } completion:^(BOOL finished) {
        [self toggleAutoHideOperationView];
        [self stop];
        [self removeFromSuperview];
        [self clean];
        if ([self.delegate respondsToSelector:@selector(closeButtonGetTap)]){
            [self.delegate closeButtonGetTap];
        }
    }];
}

- (void)clickBackBtn{
    
    [self hideControlViewAniamted:NO];
    [self toggleFullScreen];
}

- (void)tapVideoView{
    if (self.viewMode == TTAVPlayerViewUserDefineMode){
        return;
    }
    if (self.isShowControlViewAnimated){
        return;
    }
    if (self.isHideControlViews){
        [self showControlViewAniamted:YES];
    }else{
        [self hideControlViewAniamted:YES];
    }
    if ([self.delegate respondsToSelector:@selector(videoViewDidGetTap)]){
        [self.delegate videoViewDidGetTap];
    }
}


- (void)refreshProgressSlider{
    Float64 duration = CMTimeGetSeconds(self.currentItem.asset.duration);
    if (self.isDragingSlider) {
        return;
    }
    Float64 current = CMTimeGetSeconds(self.player.currentTime);
    if (duration > 0) {
        [self.slider setValue:(current / duration) animated:YES];
    }
    [self refreshTimeLabelWithCurrent:current];
}

- (void)refreshTimeLabelWithCurrent:(Float64)current {
    if (current <= 0) {
        current = 0;
    }
    Float64 duration = CMTimeGetSeconds(self.currentItem.asset.duration);
    
    if (duration == 0 || isnan(duration)) {
        [self.currentTimeLabel setText:@"00:00"];
        [self.totalTimeLabel setText:@"00:00"];
        [self.slider setUserInteractionEnabled:NO];
    } else {
        // Set time labels
        NSDate *currentTime = [NSDate dateWithTimeIntervalSince1970:current];
        NSString *timeString = [self.dateFormatter stringFromDate:currentTime];
        [self.currentTimeLabel setText:timeString];
        if (!self.isTotalTimeLabelSet){
            NSDate *totalTime = [NSDate dateWithTimeIntervalSince1970:duration];
            [self.totalTimeLabel setText:[self.dateFormatter stringFromDate:totalTime]];
            self.isTotalTimeLabelSet = YES;
        }
        [self.slider setUserInteractionEnabled:YES];
    }
}

- (void)seek:(UISlider *)slider{
    if (!self.currentItem){
        return;
    }
    
    CMTimeScale scale = self.currentItem.asset.duration.timescale;
    CMTimeValue value = slider.value * (self.currentItem.asset.duration.value / scale);
    CMTime currentTime = CMTimeMakeWithSeconds(value,scale);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        Float64 sliderTime = CMTimeGetSeconds(currentTime);
        [self toggleAutoHideOperationView];
        [self refreshTimeLabelWithCurrent:sliderTime];
    });
}

- (void)pauseRefreshProgressSlider{
    
    [self toggleAutoHideOperationView];
    
    self.isDragingSlider = YES;
}

- (void)resumeRefreshProgressSlider:(UISlider*)slider{
    [self toggleAutoHideOperationView];
    
    CMTimeScale scale = self.currentItem.asset.duration.timescale;
    CMTimeValue value = slider.value * (self.currentItem.asset.duration.value / scale);
    CMTime currentTime = CMTimeMakeWithSeconds(value,scale);
    
    __weak typeof (self) weakSelf = self;
    [self seekToTime:currentTime completionHandler:^(BOOL finished) {
        if (finished){
            weakSelf.isDragingSlider = NO;
        }
    }];
}

- (BOOL)isTotalTimeLabelSet{
    NSNumber *isSetNum = objc_getAssociatedObject(self, &timeSetAssoKey);
    return [isSetNum boolValue];
}

- (void)setIsTotalTimeLabelSet:(BOOL)isSet{
    NSNumber *isSetNum = [NSNumber numberWithBool:isSet];
    objc_setAssociatedObject(self, &timeSetAssoKey, isSetNum,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDateFormatter*)dateFormatter{
    NSDateFormatter *dateFormatter = objc_getAssociatedObject(self, &dateFormatterAssoKey);
    if (!dateFormatter){
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [dateFormatter setDateFormat:@"mm:ss"];
    }
    return dateFormatter;
}
@end
