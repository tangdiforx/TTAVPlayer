
//  TTAVPlayerView+Observer.m
//  Multimedia
//
//  Created by dylan.tang on 17/2/7.
//  Copyright © 2017年 dylan.tang. All rights reserved.
//

#import "TTAVPlayerView+Observer.h"
#import <MediaPlayer/MediaPlayer.h>
#import "TTReachability.h"
#import "TTAVPlayerView_Private.h"
#import "TTAVPlayerView+Event.h"


@implementation TTAVPlayerView (Observer)

- (void)setupNotificationObserver {
    NSNotificationCenter *ntf = [NSNotificationCenter defaultCenter];
    [ntf addObserver:self
            selector:@selector(willResignActive:)
                name:UIApplicationWillResignActiveNotification
              object:nil];
    [ntf addObserver:self selector:@selector(willEnterForground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    self.networkStatus = TTAVPlayerViewNetworkStatusUnknown;
    [ntf addObserver:self selector:@selector(statusBarOrientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    [ntf addObserver:self selector:@selector(reachChanged:) name:kReachabilityChangedNotification object:nil];
    [reach startNotifier];
}

- (void)setupPlayerObserver {
    NSNotificationCenter *ntf = [NSNotificationCenter defaultCenter];
    [ntf addObserver:self
            selector:@selector(volumeChanged:)
                name:@"AVSystemController_SystemVolumeDidChangeNotification"
              object:nil];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //[[AVAudioSession sharedInstance] setDelegate:self];
    NSError *error = nil;
    [audioSession setCategory:AVAudioSessionCategorySoloAmbient error:&error];//静音不播放声音
    [audioSession setActive:YES error:&error];//AVAudioSession这个类的单例对象必须在一开始初始化,才能监听耳机拔出事件监听
    [ntf addObserver:self selector:@selector(audioRouteChangeListenerCallback:) name:AVAudioSessionRouteChangeNotification object:nil];//设置通知
    
    //监听来电事件
    self.callCenter = [[CTCallCenter alloc] init];
    __weak typeof(self) weakSelf = self;
    self.callCenter.callEventHandler = ^(CTCall* call) {
        if ([call.callState isEqualToString:CTCallStateDisconnected])
        {
            //NSLog(@"Call has been disconnected");
        }
        else if ([call.callState isEqualToString:CTCallStateConnected])
        {
            //NSLog(@"Call has just been connected");
        }
        else if([call.callState isEqualToString:CTCallStateIncoming])
        {
            //NSLog(@"Call is incoming");
            [weakSelf pause];
        }
        else if ([call.callState isEqualToString:CTCallStateDialing])
        {
            //NSLog(@"call is dialing");
        }
        else
        {
            //NSLog(@"Nothing is done");
        }
    };
    
}

- (void)cleanPlayerObserver {
    @try {
        
        if (self.player) {
            [(AVPlayerLayer *) self.videoView.layer setPlayer:nil];
            self.player = nil;
        }
        
    } @catch (NSException *exception) {
    }
}

- (void)cleanNotificationObserver {
    NSNotificationCenter *ntf = [NSNotificationCenter defaultCenter];
    [ntf removeObserver:self];
}

- (void)clean {
    [self.player setAllowsExternalPlayback:NO];
    //    self.playerInited = NO;
    [self cleanNotificationObserver];
    [self cleanPlayerObserver];
}

#pragma mark - Public
- (void)checkNetworkStatus
{
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    
    NetworkStatus nwStatus = [reach currentReachabilityStatus];
    
    [self handleReachability:nwStatus withHandler:self.networkHandler];
    
    //初始化lastStatus
    if (nwStatus == TTAVPlayerReachableViaWiFi) {
        self.lastNetworkStatus = TTAVPlayerViewNetworkStatusWiFi;
    } else if (nwStatus == TTAVPlayerNotReachable) {
        self.lastNetworkStatus = TTAVPlayerViewNetworkStatusNotReachable;
    } else {
        self.lastNetworkStatus = TTAVPlayerViewNetworkStatusWWAN;
    }
}

#pragma mark - Private
- (void)audioRouteChangeListenerCallback:(NSNotification*)notification {
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            NSLog(@"AVAudioSessionRouteChangeReasonNewDeviceAvailable");
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            NSLog(@"AVAudioSessionRouteChangeReasonOldDeviceUnavailable");
            [self pause];
            break;
            
        case AVAudioSessionRouteChangeReasonCategoryChange:            // called at start - also when other audio wants to play
            break;
    }
}

- (void)handleReachability:(NetworkStatus)nwStatus withHandler:(void(^)(TTAVPlayerViewNetworkStatus status))handler
{
    if (self.networkStatus == TTAVPlayerViewNetworkStatusUnknown) {
        if (nwStatus == TTAVPlayerReachableViaWiFi) {
            self.networkStatus = TTAVPlayerViewNetworkStatusWiFi;
        } else if (nwStatus == TTAVPlayerNotReachable) {
            self.networkStatus = TTAVPlayerViewNetworkStatusNotReachable;
        } else {
            self.networkStatus = TTAVPlayerViewNetworkStatusWWAN;
        }
        !handler?:handler(self.networkStatus);
        return;
    }
    
    if (nwStatus == TTAVPlayerNotReachable) {
        // 无网
        if (self.networkStatus != TTAVPlayerViewNetworkStatusNotReachable) {
            self.networkStatus = TTAVPlayerViewNetworkStatusNotReachable;
            !handler?:handler(self.networkStatus);
        }
        return;
    }
    
    if (nwStatus == TTAVPlayerReachableViaWWAN) {
        //非 WiFi
        if (self.networkStatus != TTAVPlayerViewNetworkStatusWWAN) {
            self.networkStatus = TTAVPlayerViewNetworkStatusWWAN;
            !handler?:handler(self.networkStatus);
        }
        return;
    }
    
    // WiFi
    self.networkStatus = TTAVPlayerViewNetworkStatusWiFi;
    !handler?:handler(self.networkStatus);
}

#pragma mark - Reachability Notifications
- (void)reachChanged:(NSNotification*)note
{
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    [self handleReachability:[reach currentReachabilityStatus] withHandler:self.networkHandler];
    
}

#pragma mark - application notifications
/**
 *  处理播放过程中进入后台进度条会跳动的bug
 *
 */
- (void)willResignActive:(NSNotification *)ntf {
    [self pause];
}


/**
 *  处理播放过程中进入后台进度条会跳动的bug
 *
 *
 */
- (void)willEnterForground:(NSNotification *)ntf
{
}

#pragma mark - AV Player Notifications and Observers

- (void)volumeChanged:(NSNotification *)noti
{
    if (!self.isFullScreen){
        //如果不是全屏，则不需要做特殊处理
        return;
    }
    
    CGFloat volumn = [noti.userInfo[@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
    self.infoChangeView.hidden = NO;
    self.infoChangeView.alpha = 1.0f;
    [self.infoChangeView refreshUIWithVolume:volumn];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideInfoView) object:nil];
    [self performSelector:@selector(hideInfoView) withObject:nil afterDelay:2.0f];
}

- (void)hideInfoView{
    [UIView animateWithDuration:0.3f animations:^{
        self.infoChangeView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        self.infoChangeView.hidden = YES;
    }];
}

- (void)statusBarOrientationChange:(NSNotification *)notification{
    UIDeviceOrientation  orient = [UIDevice currentDevice].orientation;
    /*
     UIDeviceOrientationUnknown,
     UIDeviceOrientationPortrait,            // Device oriented vertically, home button on the bottom
     UIDeviceOrientationPortraitUpsideDown,  // Device oriented vertically, home button on the top
     UIDeviceOrientationLandscapeLeft,       // Device oriented horizontally, home button on the right
     UIDeviceOrientationLandscapeRight,      // Device oriented horizontally, home button on the left
     UIDeviceOrientationFaceUp,              // Device oriented flat, face up
     UIDeviceOrientationFaceDown             // Device oriented flat, face down   */
    
    switch (orient)
    {
        case UIDeviceOrientationPortrait:
            if (self.viewMode == TTAVPlayerViewLandScapeMode){
                [self clickFullScreenBtn];
            }
            break;
        case UIDeviceOrientationLandscapeLeft:
            if (self.viewMode == TTAVPlayerViewPortraitMode){
                [self clickFullScreenBtn];
            }
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            break;
        case UIDeviceOrientationLandscapeRight:
            break;
        default:
            break;
    }
}

@end
