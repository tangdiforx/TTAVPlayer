//
//  TTMultiMediaAVPlayer.m
//  Multimedia
//
//  Created by dylan.tang on 17/2/6.
//  Copyright © 2017年 dylan.tang. All rights reserved.
//

#import "TTMultiMediaAVPlayer.h"
#import "TTMultiMediaAVPlayer_Private.h"
#import "TTMultiMediaAVPlayer+Observer.h"

@interface TTMultiMediaAVPlayer ()

@property (nonatomic, assign) BOOL isObserved;
@property (nonatomic, assign) BOOL isLoadingFromCache;


@property (nonatomic, strong) NSURL * url;
@property (nonatomic, strong) id timeObserve;

@end

@implementation TTMultiMediaAVPlayer

+ (NSArray*)canProcessMIMETypeWhiteList {
    static NSArray* _whiteList;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _whiteList = @[@"mp4",@"mp3"];
    });
    return _whiteList;
}


+ (void)playerItemWithURL:(NSURL *)URL completionHandler:(void (^)(AVPlayerItem *item, BOOL, NSError *))handler {
    NSLog(@"=====================playerItemWithURL");
    __block AVPlayerItem *currentItem = nil;

        if ([URL.absoluteString hasPrefix:@"http"] ||
            [URL.absoluteString hasPrefix:@"https"]) {
            NSString *pathExtension = [URL pathExtension];
            BOOL canProcess = [[[self class] canProcessMIMETypeWhiteList] indexOfObject:pathExtension] != NSNotFound;
            if (canProcess) {

                //协议替换，http苹果自己会处理
                NSURLComponents * components = [[NSURLComponents alloc] initWithURL:URL resolvingAgainstBaseURL:NO];
                components.scheme = @"streaming";
//                AVURLAsset * asset = [AVURLAsset URLAssetWithURL:[components URL] options:nil];
                AVURLAsset * asset = [AVURLAsset URLAssetWithURL:URL options:nil];
                //[asset.resourceLoader setDelegate:resourceLoader queue:[TTMultimediaPlayerResourceLoader backgroundQueue]];
                NSArray *keys = @[@"tracks"];
                [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^() {
                    currentItem = [AVPlayerItem playerItemWithAsset:asset];
                    NSError *error = nil;
                    AVKeyValueStatus status = [asset statusOfValueForKey:@"tracks" error:&error];
                    
                    handler(currentItem, NO, error);
                }];
                
                NSLog(@"无缓存，播放网络文件");
            } else {
                AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:URL options:nil];
                NSArray *keys = @[@"tracks"];
                [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^() {
                    currentItem = [AVPlayerItem playerItemWithAsset:asset];
                    NSError *error = nil;
                    [asset statusOfValueForKey:@"tracks" error:&error];
                    handler(currentItem, NO, error);
                }];
            }
        }else {
            currentItem = [AVPlayerItem playerItemWithURL:URL];
            handler(currentItem, YES, nil);
            NSLog(@"播放本地文件");
        }
}


+ (void)playerWithURL:(NSURL *)URL completionHandler:(void (^)(TTMultiMediaAVPlayer *player, NSError *error))handler{
    if ([URL isKindOfClass:[NSString class]]) {
        URL = [NSURL URLWithString:(NSString*)URL];
    }
    [self playerItemWithURL:URL completionHandler:^(AVPlayerItem *item, BOOL isFromCache, NSError *error) {
        TTMultiMediaAVPlayer *avplayer = [[TTMultiMediaAVPlayer alloc] initWithPlayerItem:item];
        avplayer.isLoadingFromCache = isFromCache;
        avplayer.isObserved = NO;
        avplayer.loadedTime = 0;
        avplayer.url    = URL;
        [avplayer setupPlayerObserver];
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(avplayer, error);
        });
    }];
}

- (void)dealloc {
    NSLog(@"%s,%d,%@",__func__,__LINE__,self);
    _progress = 0.0;
    _duration = 0.0;
    [self cleanPlayerObserver];
}

- (void)reloadWithURL:(NSURL *)url completionHandler:(void (^)(NSError *error))handler{
    self.url = url;
    [[self class] playerItemWithURL:self.url completionHandler:^(AVPlayerItem *item, BOOL isFromCache, NSError *error) {
        self.isLoadingFromCache = isFromCache;
        self.loadedTime = 0;
        [self replaceCurrentItemWithPlayerItem:item];
        //Observer
        handler(error);
    }];
}

#pragma mark public method

- (void)play {
    NSLog(@"%s,%d",__func__,__LINE__);
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    if (([self.url.absoluteString hasPrefix:@"http:"] || [self.url.absoluteString hasPrefix:@"https:"]) && [reach currentReachabilityStatus] == TTAVPlayerNotReachable) {
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"您的网络不可用，请稍后再尝试"                                                                      forKey:NSLocalizedDescriptionKey];
        NSError *aError = [NSError errorWithDomain:@"fliggy.com" code:TTMultiMediaAVPlayerErrorNoNetwork userInfo:userInfo];
        self.playerStatus   = TTMultiMediaAVPlayerStatusError;
        [self.delegate playerError:aError];
        return;
    } else if (self.currentItem.error) {
        [self reloadWithURL:self.url completionHandler:^(NSError *error) {
            _isPlaying  = YES;
            [self statusWaiting];
            [super play];
        }];
    } else {
        _isPlaying  = YES;
        [self statusWaiting];
        [super play];
    }
}
-(void)playerError:(NSError*)error {
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(playerError:)]) {
            [weakSelf.delegate playerError:error];
        }
    });
}

- (void)pause {
    _isPlaying  = NO;
    NSLog(@"%s,%d",__func__,__LINE__);
    [super pause];
}

-(void)stop {
    [self stop];
}
- (void)seekToTime:(CMTime)time {
    NSLog(@"%s,%d,%2lld",__func__,__LINE__,time.value/time.timescale);
    [super seekToTime:time];;
}
-(BOOL)checkAvailable {
    NSArray *loadedTimeRanges = self.currentItem.loadedTimeRanges;
    if ([loadedTimeRanges count] > 0) {
        NSLog(@"loaded: %@", loadedTimeRanges);
        CMTimeRange timeRange       = [[loadedTimeRanges objectAtIndex:0] CMTimeRangeValue];
        Float64 current = CMTimeGetSeconds(self.currentItem.currentTime);
        Float64 start   = CMTimeGetSeconds(timeRange.start);
        Float64 duration   = CMTimeGetSeconds(timeRange.duration);
        if (current >= start && current < start + duration - 1) {
            return YES;
        }
    }
    return NO;
}
-(void)seekToTime:(CMTime)time toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter {
    NSLog(@"%s,%d,%2lld",__func__,__LINE__,time.value/time.timescale);
    [super seekToTime:time toleranceBefore:toleranceBefore toleranceAfter:toleranceAfter];
}
-(void)seekToTime:(CMTime)time toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter completionHandler:(void (^)(BOOL))completionHandler {
    
    NSLog(@"%s,%d,%2lld",__func__,__LINE__,time.value/time.timescale);
    //*
    __weak typeof (self) weakSelf = self;
    [weakSelf statusWaiting];
    [super seekToTime:time toleranceBefore:toleranceBefore toleranceAfter:toleranceAfter completionHandler:completionHandler];
}
-(void)statusWaiting {
    __weak typeof (self) weakSelf = self;
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    if ([reach currentReachabilityStatus] == TTAVPlayerNotReachable) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"您的网络不可用，请稍后再尝试"                                                                      forKey:NSLocalizedDescriptionKey];
        NSError *aError = [NSError errorWithDomain:@"fliggy.com" code:TTMultiMediaAVPlayerErrorNoNetwork userInfo:userInfo];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(playerError:)]) {
                [weakSelf.delegate playerError:aError];
            }
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf.playerStatus == TTMultiMediaAVPlayerStatusWaiting) {
                return;
            }
            weakSelf.playerStatus   = TTMultiMediaAVPlayerStatusWaiting;
            if (weakSelf && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(playerWaiting)]) {
                [weakSelf.delegate playerWaiting];
            }
        });
    }
}
@end
