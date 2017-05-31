//
//  TTAVPlayerErrorView.m
//  Multimedia
//
//  Created by dylan.tang on 17/2/2.
//  Copyright © 2017年 dylan.tang. All rights reserved.
//

#import "TTAVPlayerErrorView.h"


@interface TTAVPlayerErrorView ()

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *closeBtn;

@end

@implementation TTAVPlayerErrorView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.backgroundColor = [UIColor blackColor];
    [self setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _imageView.image = [UIImage imageNamed:@"TTAVPlayer.bundle/multimedia_refresh"];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.userInteractionEnabled = YES;
    [self addSubview:_imageView];
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc]init];
    [tapGes addTarget:self action:@selector(toggleRetry)];
    [_imageView addGestureRecognizer:tapGes];
    
    _titleLabel = [[UILabel alloc]init];
    _titleLabel.font = [UIFont systemFontOfSize:14.0f];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.numberOfLines = 1;
    [_titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:_titleLabel];
    
    self.closeBtn = [[UIButton alloc]init];
    self.closeBtn.imageEdgeInsets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
    [self.closeBtn setImage:[UIImage imageNamed:@"TTAVPlayer.bundle/multimedia_close"] forState:UIControlStateNormal];
    [self.closeBtn addTarget:self action:@selector(clickCloseBtn) forControlEvents:UIControlEventTouchDown];
    [self addSubview:self.closeBtn];
}

- (void)toggleRetry{
    self.retryBlock();
}

- (void)clickCloseBtn{
    self.closeBlock();
}

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
    [self.titleLabel sizeToFit];
    [self layoutIfNeeded];
}

- (void)layoutSubviews{
    self.imageView.frame = CGRectMake((self.bounds.size.width - 50.0f)/2, (self.bounds.size.height - 50.0f)/2, 50.0f, 50.0f);
    self.titleLabel.origin = CGPointMake((self.bounds.size.width - self.titleLabel.width)/2 , _imageView.bottom + 20.0f);
    self.closeBtn.frame = CGRectMake((self.bounds.size.width - 50.0f), 0.0f, 50.0f, 50.0f);
}

- (void)startRotation
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    animation.fromValue = @0.0;
    animation.toValue   = @(2*M_PI);
    animation.duration = 0.9;
    animation.fillMode = kCAFillModeForwards;
    animation.repeatCount = 3;
    animation.removedOnCompletion = NO;
//    [self.imageView.layer addAnimation:animation forKey:kTBAVPlayerErrorViewAnimationKeyName];
}

- (void)stopRotation
{
//    [self.imageView.layer removeAnimationForKey:kTBAVPlayerErrorViewAnimationKeyName];
}

@end
