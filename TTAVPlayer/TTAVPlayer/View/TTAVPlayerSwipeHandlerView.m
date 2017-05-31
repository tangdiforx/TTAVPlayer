//
//  TTAVPlayerSwipeHandlerView.m
//  Multimedia
//
//  Created by dylan.tang on 17/2/10.
//  Copyright © 2017年 dylan.tang. All rights reserved.
//

#import "TTAVPlayerSwipeHandlerView.h"
#import "TTAVPlayerInfoChangeView.h"
#import "TTAVPlayerAdjustPlayProgressView.h"
#import <MediaPlayer/MediaPlayer.h>


@interface TTAVPlayerSwipeHandlerView ()

@property (nonatomic,strong) TTAVPlayerInfoChangeView *brightnessView;

@property (nonatomic,strong) TTAVPlayerAdjustPlayProgressView *playProgressView;

@end

@implementation TTAVPlayerSwipeHandlerView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self setup];
    }
    return self;
}

- (void)layoutSubviews{
    
    _brightnessView.frame = CGRectMake((self.bounds.size.width - 143.0f)/2, 90.0f, 143.0f, 57.0f);
    
    _playProgressView.frame = CGRectMake((self.bounds.size.width - 143.0f)/2, 90.0f, 143.0f, 77.0f);
}

- (void)setup{
    
    _brightnessView = [[TTAVPlayerInfoChangeView alloc]initWithFrame:CGRectZero];
    [self addSubview:_brightnessView];
    _brightnessView.hidden = YES;
    
    _playProgressView = [[TTAVPlayerAdjustPlayProgressView alloc]initWithFrame:CGRectZero];
    [self addSubview:_playProgressView];
    _playProgressView.hidden = YES;
}

//- (void)handleSwipe:(UIPanGestureRecognizer*)panGes{
//    UIGestureRecognizerState state =  panGes.state;
//    if (state == UIGestureRecognizerStateBegan){
//        CGPoint startPoint = [panGes locationInView:self];
//        if (startPoint.x <= self.bounds.size.width/2){
//            self.part = TTAVPlayerViewPartLeft;
//        }else{
//            self.part = TTAVPlayerViewPartRight;
//        }
//        self.direction = TTPlayerSwipeDirectionNone;
//    }else if(state == UIGestureRecognizerStateChanged){
//        CGPoint transPoint = [panGes translationInView:self];
////        CGPoint transSpeed = [panGes velocityInView:self];
//        switch (self.direction) {
//            case TTPlayerSwipeDirectionNone:
//                self.direction = [self directionWithTranslation:transPoint];
//            case TTPlayerSwipeDirectionHorizontal:
//                [self changePlayProgress];
//                break;
//            case TTPlayerSwipeDirectionLeftVertical:
//                if (transPoint.y > 0){
//                    [self changeScreenBrightnessWithOffset:-0.01];
//                }else{
//                    [self changeScreenBrightnessWithOffset:+0.01];
//                }
//                break;
//
//            case TTPlayerSwipeDirectionRightVertical:
//                if (transPoint.y > 0){
//                    [self changeVolumeWithOffset:-0.03];
//                }else{
//                    [self changeVolumeWithOffset:+0.03];
//                }
//                break;
//            default:
//                break;
//        }
//
//    }
//}

- (void)swipeLeftVertical:(CGPoint)translation{
    if (translation.y > 0){
        [self changeScreenBrightnessWithOffset:-0.005];
    }else if (translation.y < 0){
        [self changeScreenBrightnessWithOffset:+0.005];
    }
}

- (void)swipeRightVertical:(CGPoint)translation{
    if (translation.y > 0){
        [self changeVolumeWithOffset:-0.01];
    }else if (translation.y < 0){
        [self changeVolumeWithOffset:+0.01];
    }
}

- (void)swipeHorizontalToAdjustPlayProgress:(Float64)currentTime withTotalTime:(Float64)totalTime isForward:(BOOL)isForward{
    _playProgressView.alpha = 1.0f;
    _playProgressView.hidden = NO;
    [_playProgressView refreshUIWithPlayProgress:currentTime withTotalTime:totalTime isForward:isForward];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hidePlayProgressView) object:nil];
    [self performSelector:@selector(hidePlayProgressView) withObject:nil afterDelay:0.2f];
}

- (void)changeScreenBrightnessWithOffset:(float)offset{
    
    _brightnessView.alpha = 1.0f;
    _brightnessView.hidden = NO;
    [_brightnessView refreshUIWithBrightnessWithOffset:offset];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideInfoView) object:nil];
    [self performSelector:@selector(hideInfoView) withObject:nil afterDelay:0.2f];
}

- (void)changeVolumeWithOffset:(float)offset{
    
    MPMusicPlayerController* musicController = [MPMusicPlayerController applicationMusicPlayer];
    musicController.volume += offset;
}

- (void)hideInfoView{
    [UIView animateWithDuration:0.3f animations:^{
        self.brightnessView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        self.brightnessView.hidden = YES;
    }];
}

- (void)hidePlayProgressView{
    [UIView animateWithDuration:0.3f animations:^{
        self.playProgressView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        self.playProgressView.hidden = YES;
    }];
}


- (void)changePlayProgress{
    
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    if(CGRectContainsPoint(CGRectMake(0.0f, self.height - 50.0f, self.width, 50.0f), point)){
        return NO;// 这里是为了解决swipeView层遮住了operation层的暂停和播放按钮
    }
    return [super pointInside:point withEvent:event];
}

@end
