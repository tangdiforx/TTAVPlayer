//
//  TTAVPlayerAdjustPlayProgressView.m
//  Multimedia
//
//  Created by dylan.tang on 17/2/10.
//  Copyright © 2017年 dylan.tang. All rights reserved.
//

#import "TTAVPlayerAdjustPlayProgressView.h"

@interface TTAVPlayerAdjustPlayProgressView ()

@property (nonatomic,strong) UIImageView *iconIv;

@property (nonatomic,strong) UILabel *symbolLabel;

@property (nonatomic,strong) UILabel *seekTimeLabel;

@property (nonatomic,strong) UILabel *totalTimeLabel;

@property (nonatomic,strong) NSDateFormatter *dateFormatter;

@property (nonatomic,strong) UIImage *forwardImg;

@property (nonatomic,strong) UIImage *backwardImg;

@property (nonatomic,strong) UIProgressView *progressView;

@end

@implementation TTAVPlayerAdjustPlayProgressView

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
    self.iconIv = [[UIImageView alloc]initWithFrame:CGRectZero];
    [self addSubview:_iconIv];
    
    self.seekTimeLabel = [[UILabel alloc]init];
    self.seekTimeLabel.font = [UIFont systemFontOfSize:14.0f];
    self.seekTimeLabel.textColor = [UIColor colorWithRed:1.0f green:195.0f/255.0f blue:0.0f alpha:1.0f];
    
    [self addSubview:self.seekTimeLabel];
    
    self.symbolLabel = [[UILabel alloc]init];
    self.symbolLabel.font = [UIFont systemFontOfSize:14.0f];
    self.symbolLabel.textColor = [UIColor whiteColor];
    self.symbolLabel.text = @"/";
    [self.symbolLabel sizeToFit];
    [self addSubview:self.symbolLabel];
    
    self.totalTimeLabel = [[UILabel alloc]init];
    self.totalTimeLabel.font = [UIFont systemFontOfSize:14.0f];
    self.totalTimeLabel.textColor = [UIColor whiteColor];
    [self addSubview:self.totalTimeLabel];
    
    self.progressView = [[UIProgressView alloc]init];
    self.progressView.progressTintColor = [UIColor whiteColor];
    self.progressView.progress = 0.0f;
    [self addSubview:self.progressView];
    
    self.forwardImg = [UIImage imageNamed:@"TTAVPlayer.bundle/multimedia_forward"];
    self.backwardImg = [UIImage imageNamed:@"TTAVPlayer.bundle/multimedia_backward"];
}

- (void)layoutSubviews{
    self.iconIv.frame = CGRectMake((self.width - 26.0f)/2, 16.0f, 30.0f, 30.0f);
    
    self.symbolLabel.origin = CGPointMake((self.width - self.symbolLabel.width)/2, 48.0f);
    
    self.seekTimeLabel.origin = CGPointMake(self.symbolLabel.left - self.seekTimeLabel.width - 5.0f, 48.0f);
    self.totalTimeLabel.origin = CGPointMake(self.symbolLabel.right + 5.0f, 48.0f);

    self.progressView.frame = CGRectMake(9.0f, self.symbolLabel.bottom + 6.0f, self.width - 18.0f, 2.0f);
}

- (void)refreshUIWithPlayProgress:(Float64)currentTime withTotalTime:(Float64)totalTime isForward:(BOOL)isForward{
    if (isForward){
        [self.iconIv setImage:self.forwardImg];
    }else{
        [self.iconIv setImage:self.backwardImg];
    }
    
    self.progressView.progress = currentTime/totalTime;
    
    [self.dateFormatter setDateFormat:(totalTime >= 3600 ? @"HH:mm:ss" : @"mm:ss")];
    NSDate *currentDate = [NSDate dateWithTimeIntervalSince1970:currentTime];
    self.seekTimeLabel.text = [self.dateFormatter stringFromDate:currentDate];
    [self.seekTimeLabel sizeToFit];
    
    NSDate *totalTimeDate = [NSDate dateWithTimeIntervalSince1970:totalTime];
    self.totalTimeLabel.text = [self.dateFormatter stringFromDate:totalTimeDate];
    [self.totalTimeLabel sizeToFit];
    
    [self layoutIfNeeded];
}

- (NSDateFormatter*)dateFormatter{
    if (!_dateFormatter){
        _dateFormatter = [[NSDateFormatter alloc]init];
        [_dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    }
    return _dateFormatter;
}

@end
