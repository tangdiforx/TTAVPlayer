//
//  TTAVPlayerLoadingView.m
//  Multimedia
//
//  Created by 凡铁 on 17/2/20.
//  Copyright © 2017年 Alipay. All rights reserved.
//

#import "TTAVPlayerLoadingView.h"

@interface TTAVPlayerLoadingView ()

@property (nonatomic,strong) UIImageView *loadingImg;

@end

@implementation TTAVPlayerLoadingView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        _loadingImg = [[UIImageView alloc]init];
        [_loadingImg setImage:[UIImage imageNamed:@"TTAVPlayer.bundle/multimedia_loading"]];
        [self addSubview:_loadingImg];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _loadingImg.frame = self.bounds;
}

- (void)showLoading{
    [UIView animateWithDuration:0.5 animations:^{
        self.loadingImg.transform = CGAffineTransformRotate(self.loadingImg.transform, M_PI);
    } completion:^(BOOL finished) {
        if (finished){
            [self showLoading];
        }else{
            self.loadingImg.transform = CGAffineTransformIdentity;
        }
    }];
}

- (void)hideLoading{
    [self.loadingImg.layer removeAllAnimations];
}

- (void)setHidden:(BOOL)hidden{
    [super setHidden:hidden];
    if (hidden){
        [self hideLoading];
    }else{
        [self showLoading];
    }
}

@end
