//
//  TTAVPlayerInfoChangeView.m
//  Multimedia
//
//  Created by dylan.tang on 17/2/10.
//  Copyright © 2017年 dylan.tang. All rights reserved.
//

#import "TTAVPlayerInfoChangeView.h"
#import <MediaPlayer/MediaPlayer.h>

@interface TTAVPlayerInfoChangeView ()

@property (nonatomic,strong) MPVolumeView *volumeView;

@property (nonatomic,strong) UISlider *volumeSlider;//用来调整音量的slider

@property (nonatomic,strong) UISlider *showSlider;//真正用来显示的Slider

@property (nonatomic,strong) UIImageView *iconIv;

@end

@implementation TTAVPlayerInfoChangeView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self initUI];
    }
    return self;
}

- (void)initUI{
    self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.7f];
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 3.0f;
    //为了在全屏的时候可以屏蔽掉系统的音量View
    self.volumeView = [[MPVolumeView alloc]initWithFrame:CGRectZero];
    [self addSubview:self.volumeView];
    for (UIView *view in [_volumeView subviews]) {
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            _volumeSlider = (UISlider *)view;
            _volumeSlider.hidden = YES;
        }else if([view.class.description isEqualToString:@"MPButton"]){
            view.hidden = YES;
        }
    }
    
    self.iconIv = [[UIImageView alloc]initWithFrame:CGRectZero];
    [self addSubview:_iconIv];
    
    self.showSlider = [[UISlider alloc]init];
    [self.showSlider setThumbImage:[self createImageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
    [self.showSlider setMinimumTrackTintColor:[UIColor whiteColor]];
    [self addSubview:self.showSlider];
}

- (UIImage *) createImageWithColor: (UIColor *) color{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

- (void)layoutSubviews{
    self.iconIv.frame = CGRectMake((self.bounds.size.width - 30.0f)/2, 7.0f, 30.0f, 30.0f);
    self.showSlider.frame = CGRectMake(9.0f, self.bounds.size.height - 6.0f - 6.0f, self.bounds.size.width - 18.0f, 6.0f);
}

- (void)refreshUIWithBrightnessWithOffset:(float)brightness{
    [self.iconIv setImage:[UIImage imageNamed:@"TTAVPlayer.bundle/multimedia_brightness"]];
    
    [UIScreen mainScreen].brightness += brightness;
    [_showSlider setValue:[UIScreen mainScreen].brightness];
    
    [self layoutIfNeeded];
}

- (void)refreshUIWithVolume:(float)volume{
    [self.iconIv setImage:[UIImage imageNamed:@"TTAVPlayer.bundle/multimedia_avplayer_volume"]];
    [_showSlider setValue:volume];
    
    [self layoutIfNeeded];
}

- (void)refreshUIWithPlayProgress:(id)currentTime withTotalTime:(id)totalTime isForward:(BOOL)isForward{
    
}

@end
