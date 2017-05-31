//
//  TTAVPlayerView+ViewMode.m
//  Multimedia
//
//  Created by dylan.tang on 17/2/5.
//  Copyright © 2017年 dylan.tang. All rights reserved.
//

//  14/25
const static CGFloat screenRate = 0.56;

const static CGFloat edgeInset = 10.0f;

#import "TTAVPlayerView+ViewMode.h"
#import "TTAVPlayerView+Event.h"
#import "TTAVPlayerView_Private.h"
#import "TTAVPlayerSwipeHandlerView.h"
#import <objc/runtime.h>

@interface TTAVPlayerView ()

/** //确认滑动发生在左边还是在右边 */
@property (nonatomic,assign) TTAVPlayerViewPart part;

@property (nonatomic,assign) TTAVPlayerSwipeDirection direction;

@end

static char partAssoKey;
static char directionAssoKey;

@implementation TTAVPlayerView (ViewMode)

- (void)setupUIWithViewMode:(TTAVPlayerViewMode)mode{
    [self initViews];
    switch (mode) {
        case TTAVPlayerViewNormalMode:
            [self setupUINormalMode];
            break;
        case TTAVPlayerViewPortraitMode:
            [self setupUIPortraitMode];
            break;
        case TTAVPlayerViewLandScapeMode:
            [self setupUILandScapeMode];
            break;
        case TTAVPlayerViewMuteMode:
            [self setupUIMuteMode];
            break;
        case TTAVPlayerViewUserDefineMode:
            [self setupUserDefineMode];
        default:
            break;
    }
}

- (void)setupUserDefineMode{
    self.viewMode = TTAVPlayerViewUserDefineMode;
    __weak typeof (self) weakSelf = self;
    if ([[UIApplication sharedApplication].keyWindow.subviews containsObject:weakSelf]) {
        [weakSelf removeFromSuperview];
    }
    if (self.mySuperView && ![self.mySuperView.subviews containsObject:weakSelf]) {
        [self.mySuperView addSubview:weakSelf];
        [self.mySuperView sendSubviewToBack:weakSelf];
        self.frame = self.originFrame;
        [self layoutIfNeeded];
        return;
    }
    self.headControlView.hidden = YES;
    self.bottomControlView.hidden = YES;
    
    self.backBtn.hidden = YES;
    self.handleSwipeView.hidden = YES;
    self.titleLabel.hidden = YES;
    self.volumeView.hidden = YES;
    self.infoChangeView.hidden = YES;
    self.closeBtn.hidden = YES;
    self.videoView.frame = self.bounds;
    
    [self.player setMuted:NO];
    
    if ([self.delegate respondsToSelector:@selector(videoUIDidLoad)]){
        [self.delegate videoUIDidLoad];
    }

}

//上下操作栏的高度为50.0f
- (void)setupUINormalMode{
    self.viewMode = TTAVPlayerViewNormalMode;
    __weak typeof (self) weakSelf = self;
    if ([[UIApplication sharedApplication].keyWindow.subviews containsObject:weakSelf]) {
        [weakSelf removeFromSuperview];
    }
    if (self.mySuperView && ![self.mySuperView.subviews containsObject:weakSelf]) {
        [self.mySuperView addSubview:weakSelf];
        [self.mySuperView sendSubviewToBack:weakSelf];
        self.frame = self.originFrame;
        [self layoutIfNeeded];
        return;
    }
    self.headControlView.hidden = NO;
    self.bottomControlView.hidden = NO;
    
    self.backBtn.hidden = YES;
    self.handleSwipeView.hidden = YES;
    self.titleLabel.hidden = YES;
    self.volumeView.hidden = YES;
    self.infoChangeView.hidden = YES;
    self.closeBtn.hidden = NO;
    
    self.videoView.frame = self.bounds;
    
    self.loadingView.frame = CGRectMake((self.videoView.width - 30.0f)/2, (self.videoView.height - 30.0f)/2, 30.0f, 30.0f);
    
    self.errorView.frame = self.videoView.bounds;
    
    self.headControlView.frame = CGRectMake(0.0f, 0.0f, self.width, 50.0f);
    
    self.closeBtn.frame = CGRectMake(self.headControlView.width - 50.0f, 0.0f, 50.0f, 50.0f);
    
    self.bottomControlView.frame = CGRectMake(0.0f, self.videoView.height - 50.0f, self.width, 50.0f);
    
    [self setupBottomControlView];
    [self.fullScreenBtn setSelected:NO];
    
    [self.player setMuted:NO];
    
    [self toggleAutoHideOperationView];
    
    if ([self.delegate respondsToSelector:@selector(videoUIDidLoad)]){
        [self.delegate videoUIDidLoad];
    }
}

- (void)setupUIPortraitMode{
    
    self.viewMode = TTAVPlayerViewPortraitMode;
    self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.9];
    
    __weak typeof (self) weakSelf = self;
    
    if (![[UIApplication sharedApplication].keyWindow.subviews containsObject:weakSelf]){
        self.mySuperView = self.superview;
        CGFloat width = [UIApplication sharedApplication].keyWindow.size.width;
        CGFloat height =[UIApplication sharedApplication].keyWindow.size.height;
        [[UIApplication sharedApplication].keyWindow addSubview:weakSelf];
        weakSelf.frame = CGRectMake(0.0f, 0.0f, width, height);
        [self layoutIfNeeded];
        return;
    }
    self.headControlView.hidden = NO;
    self.bottomControlView.hidden = NO;
    self.titleLabel.hidden = YES;
    self.backBtn.hidden = YES;
    self.handleSwipeView.hidden = YES;
    self.infoChangeView.hidden = YES;
    self.volumeView.hidden = YES;
    self.closeBtn.hidden = NO;
    
    self.videoView.frame = CGRectMake(0.0f, (self.height - self.width * screenRate)/2, self.width, self.width * screenRate);
    
    self.loadingView.frame = CGRectMake((self.videoView.width - 30.0f)/2, (self.videoView.height - 30.0f)/2, 30.0f, 30.0f);
    
    self.errorView.frame = self.videoView.bounds;
    
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    self.headControlView.frame = CGRectMake(0.0f, statusBarHeight, self.width, 50.0f);
    
    self.closeBtn.frame = CGRectMake(self.width - 50.0f, 0.0f, 50.0f, 50.0f);
    
    self.bottomControlView.frame = CGRectMake(0.0f, self.videoView.height - 50.0f, self.width, 50.0f);
    [self setupBottomControlView];
    [self.fullScreenBtn setSelected:NO];
    
    [self.player setMuted:NO];
    
    [self toggleAutoHideOperationView];
    
    if ([self.delegate respondsToSelector:@selector(videoUIDidLoad)]){
        [self.delegate videoUIDidLoad];
    }
    
}

- (void)setupUIMuteMode{
    self.viewMode = TTAVPlayerViewMuteMode;
    
    __weak typeof (self) weakSelf = self;
    if ([[UIApplication sharedApplication].keyWindow.subviews containsObject:weakSelf]) {
        [weakSelf removeFromSuperview];
    }
    if (self.mySuperView && ![self.mySuperView.subviews containsObject:weakSelf]) {
        [self.mySuperView addSubview:weakSelf];
        [self.mySuperView sendSubviewToBack:weakSelf];
        self.frame = self.originFrame;
        [self layoutIfNeeded];
        return;
    }
    self.headControlView.hidden = YES;
    self.bottomControlView.hidden = YES;
    self.backBtn.hidden = YES;
    self.handleSwipeView.hidden = YES;
    self.titleLabel.hidden = YES;
    self.volumeView.hidden = YES;
    self.infoChangeView.hidden = YES;
    self.closeBtn.hidden = NO;
    self.videoView.frame = self.bounds;
    
    self.loadingView.frame = CGRectMake((self.videoView.width - 30.0f)/2, (self.videoView.height - 30.0f)/2, 30.0f, 30.0f);
    self.errorView.frame = self.videoView.bounds;
    [self.player setMuted:YES];
    self.originMuteFrame = self.frame;
    if ([self.delegate respondsToSelector:@selector(videoUIDidLoad)]){
        [self.delegate videoUIDidLoad];
    }
}

- (void)setupUILandScapeMode{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    self.isFullScreen = YES;
    self.closeBtn.hidden = YES;
    self.headControlView.hidden =  NO;
    self.bottomControlView.hidden = NO;
    self.volumeView.hidden = NO;
    self.backBtn.hidden = NO;
    self.titleLabel.hidden = NO;
    self.handleSwipeView.hidden = NO;
    
    //目前没有直接转到横屏的情况，videoView的旋转由主类父类，故这里不再设置。
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    self.loadingView.frame = CGRectMake((width - 30.0f)/2, (height - 30.0f)/2, 30.0f, 30.0f);
    
    self.errorView.frame = self.videoView.bounds;
    
    self.handleSwipeView.frame = self.bounds;
    UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipe:)];
    [self.handleSwipeView addGestureRecognizer:panGes];
    self.infoChangeView.frame = CGRectMake((self.bounds.size.width - 143.0f)/2, 90.0f, 143.0f, 57.0f);
    
    self.headControlView.frame = CGRectMake(0.0f, 0.0f, width, 50.0f);
    self.bottomControlView.frame = CGRectMake(0.0f, self.videoView.bounds.size.height - 50.0f, width, 50.0f);
    
    self.backBtn.frame = CGRectMake(0.0f, 0.0f, 50.0f, 50.0f);
    
    self.titleLabel.frame = CGRectMake(self.backBtn.right, 0.0f, width - 50.0f * 2, 50.0f);
    
    [self setupBottomControlView];
    
    [self.fullScreenBtn setSelected:YES];
    
    self.viewMode = TTAVPlayerViewLandScapeMode;
    [self.player setMuted:NO];
    
    [self toggleAutoHideOperationView];
    if ([self.delegate respondsToSelector:@selector(videoUIDidLoad)]){
        [self.delegate videoUIDidLoad];
    }
    
}

- (void)setupBottomControlView{
    CGFloat width = self.bounds.size.width;
    
    self.playBtn.frame = CGRectMake(0.0f, 0.0f, 50.0f, 50.0f);
    
    self.currentTimeLabel.origin = CGPointMake(self.playBtn.right, (self.bottomControlView.height - self.currentTimeLabel.height)/2);
    
    self.slider.frame = CGRectMake(self.currentTimeLabel.right + 10.0f,(self.bottomControlView.height - 10.0f)/2 , width - 50.0f * 2 - self.currentTimeLabel.width - self.totalTimeLabel.width - 20.0f, 10.0f);
    
    self.totalTimeLabel.origin = CGPointMake(self.slider.right + 10.0f, (self.bottomControlView.height - self.totalTimeLabel.height)/2);
    
    self.currentTimeLabel.hidden = NO;
    self.totalTimeLabel.hidden = NO;

    self.fullScreenBtn.frame = CGRectMake(width - 50.0f, 0.0f, 50.0f, 50.0f);
}

- (void)layoutSubviews{
    if (self.isCloseAnimation){
        return;
    }
    [super layoutSubviews];
    switch (self.viewMode) {
        case TTAVPlayerViewNormalMode:
            [self setupUINormalMode];
            break;
        case TTAVPlayerViewPortraitMode:
            [self setupUIPortraitMode];
            break;
        case TTAVPlayerViewLandScapeMode:
            [self setupUILandScapeMode];
            break;
        case TTAVPlayerViewMuteMode:
            [self setupUIMuteMode];
            break;
        default:
            break;
    }
    
}

#pragma mark - UI Init

- (void)initViews{
    self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.9];
    UITapGestureRecognizer *playerViewTapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapVideoView)];
    [self addGestureRecognizer:playerViewTapGes];
    
    self.videoView = [[TTAVPlayerInternalView alloc]initWithFrame:CGRectZero];
    self.videoView.userInteractionEnabled = YES;
    self.clipsToBounds = YES;
    [self addSubview:self.videoView];
    
    self.loadingView = [[TTAVPlayerLoadingView alloc]initWithFrame:CGRectZero];
    self.loadingView.hidden = YES;
    [self.videoView addSubview:self.loadingView];
    
    UITapGestureRecognizer *videoTapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapVideoView)];
    [self.videoView addGestureRecognizer:videoTapGes];
    
    if (self.viewMode != TTAVPlayerViewUserDefineMode){
        self.handleSwipeView = [[TTAVPlayerSwipeHandlerView alloc]initWithFrame:CGRectZero];
        self.handleSwipeView.hidden = YES;
        [self.videoView addSubview:self.handleSwipeView];
    }
    
    self.errorView = [[TTAVPlayerErrorView alloc]init];
    __weak typeof (self) weakSelf = self;
    self.errorView.retryBlock = ^ {
        [weakSelf replay];
    };
    self.errorView.closeBlock = ^{
        [weakSelf clickCloseBtn];
    };
    self.errorView.hidden = YES;
    [self.videoView addSubview:self.errorView];
    
    self.headControlView = [[UIView alloc]init];
    [self addSubview:self.headControlView];
    
    self.bottomControlView = [[UIView alloc]init];
    [self.videoView addSubview:self.bottomControlView];
    
    self.playBtn = [[UIButton alloc]init];
    self.playBtn.imageEdgeInsets = UIEdgeInsetsMake(edgeInset, edgeInset, edgeInset, edgeInset);
    [self.playBtn setImage:[UIImage imageNamed:@"TTAVPlayer.bundle/multimedia_avplayer_pause"] forState:UIControlStateNormal];
    [self.playBtn setImage:[UIImage imageNamed:@"TTAVPlayer.bundle/multimedia_avplayer_play"] forState:UIControlStateSelected];
    [self.playBtn addTarget:self action:@selector(clickPlayBtn) forControlEvents:UIControlEventTouchDown];
    [self.bottomControlView addSubview:self.playBtn];
    
    self.currentTimeLabel = [[TTAVPlayerTimeLabel alloc]init];
    [self.currentTimeLabel setText:@"00:00 "];//防止出现计算bug，多出一个空格距离
    [self.currentTimeLabel sizeToFit];
    self.currentTimeLabel.hidden = YES;
    [self.bottomControlView addSubview:self.currentTimeLabel];
    
    
    self.totalTimeLabel = [[TTAVPlayerTimeLabel alloc]init];
    [self.totalTimeLabel setText:@"00:00 "];
    [self.totalTimeLabel sizeToFit];
    self.totalTimeLabel.hidden = YES;
    [self.bottomControlView addSubview:self.totalTimeLabel];
    

    self.slider = [[TTAVPlayerSlider alloc]init];
    [self.slider addTarget:self action:@selector(seek:) forControlEvents:UIControlEventValueChanged];
    [self.slider addTarget:self action:@selector(pauseRefreshProgressSlider) forControlEvents:UIControlEventTouchDown];
    [self.slider addTarget:self action:@selector(resumeRefreshProgressSlider:) forControlEvents:UIControlEventTouchUpInside];
    [self.slider addTarget:self action:@selector(resumeRefreshProgressSlider:) forControlEvents:UIControlEventTouchUpOutside];
    [self.slider addTarget:self action:@selector(resumeRefreshProgressSlider:) forControlEvents:UIControlEventTouchCancel];
    
    [self.bottomControlView addSubview:self.slider];
    
    self.fullScreenBtn = [[UIButton alloc]init];
    self.fullScreenBtn.imageEdgeInsets = UIEdgeInsetsMake(edgeInset, edgeInset, edgeInset, edgeInset);
    [self.fullScreenBtn setImage:[UIImage imageNamed:@"TTAVPlayer.bundle/multimedia_avplayer_fullscreen"] forState:UIControlStateNormal];
    [self.fullScreenBtn setImage:[UIImage imageNamed:@"TTAVPlayer.bundle/multimedia_avplayer_unfullscreen"] forState:UIControlStateSelected];
    [self.fullScreenBtn addTarget:self action:@selector(clickFullScreenBtn) forControlEvents:UIControlEventTouchDown];
    [self.bottomControlView addSubview:self.fullScreenBtn];
    
    self.closeBtn = [[UIButton alloc]init];
    self.closeBtn.imageEdgeInsets = UIEdgeInsetsMake(edgeInset, edgeInset, edgeInset, edgeInset);
    [self.closeBtn setImage:[UIImage imageNamed:@"TTAVPlayer.bundle/multimedia_close"] forState:UIControlStateNormal];
    [self.closeBtn addTarget:self action:@selector(clickCloseBtn) forControlEvents:UIControlEventTouchDown];
    [self.headControlView addSubview:self.closeBtn];
    
    self.backBtn = [[UIButton alloc]init];
    self.backBtn.imageEdgeInsets = UIEdgeInsetsMake(edgeInset, edgeInset, edgeInset, edgeInset);
    [self.backBtn setImage:[UIImage imageNamed:@"TTAVPlayer.bundle/multimedia_back.png"] forState:UIControlStateNormal];
    [self.backBtn addTarget:self action:@selector(clickBackBtn) forControlEvents:UIControlEventTouchDown];
    [self.headControlView addSubview:self.backBtn];
    
    self.titleLabel = [[UILabel alloc]init];
    self.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [self.titleLabel setText:self.videoTitle];
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.hidden = YES;
    [self.headControlView addSubview:self.titleLabel];
    
    self.infoChangeView = [[TTAVPlayerInfoChangeView alloc]initWithFrame:CGRectZero];
    self.infoChangeView.hidden = YES;
    [self addSubview:self.infoChangeView];
    
    self.volumeView = [[MPVolumeView alloc]initWithFrame:CGRectMake(-1000.0f, 0.0f, 0.0f, 0.0f)];
    [self addSubview:self.volumeView];
    
}

#pragma mark - ViewMode Change

- (void)changeToMuteMode{
    self.originViewMode = self.viewMode;
    self.originFrame = self.frame;
    [self setupUIMuteMode];
}

- (void)changeToNormalMode{
    self.originViewMode = self.viewMode;
    self.originFrame = self.frame;
    [self setupUINormalMode];
    [self showControlViewAniamted:YES];
}

- (void)changeToLandScapeMode{
    
    self.originViewMode = self.viewMode;
    [self setupUILandScapeMode];
    [self showControlViewAniamted:YES];
    if ([self.delegate respondsToSelector:@selector(onVideoFullScreen)]){
        [self.delegate onVideoFullScreen];
    }
}

- (void)changeToPortraitMode{
    self.originViewMode = self.viewMode;
    self.originFrame = self.frame;
    [UIView animateWithDuration:0.2f animations:^{
        [self setupUIPortraitMode];
    }];
    [self showControlViewAniamted:YES];
}

- (void)backToOriginViewMode{
    switch (self.originViewMode) {
        case TTAVPlayerViewNormalMode:
            [self setupUINormalMode];
            break;
        case TTAVPlayerViewPortraitMode:
            [self setupUIPortraitMode];
            break;
        case TTAVPlayerViewMuteMode:
            [self setupUIMuteMode];
            break;
        default:
            break;
    }
    [self showControlViewAniamted:YES];
}

- (void)hideControlViewAniamted:(BOOL)animated{
    if (self.isHideControlViews){
        return;
    }
    CGFloat width = self.bounds.size.width;
    
    if (animated){
        self.isShowControlViewAnimated = YES;
        
        [UIView animateWithDuration:0.5f animations:^{
            self.headControlView.top -= 50.0f;
            self.bottomControlView.bottom += 50.0f;
        } completion:^(BOOL finished) {
            self.headControlView.hidden = YES;
            self.bottomControlView.hidden = YES;
            self.isHideControlViews = YES;
            
            self.headControlView.frame = CGRectMake(0.0f, -50.0f, width, 50.0f);
            self.bottomControlView.frame = CGRectMake(0.0f, self.videoView.bounds.size.height, width, 50.0f);
            
            self.isShowControlViewAnimated = NO;
            
        }];
    }else{
        self.headControlView.hidden = YES;
        self.bottomControlView.hidden = YES;
        self.isHideControlViews = YES;
        
        self.headControlView.frame = CGRectMake(0.0f, -50.0f, width, 50.0f);
        self.bottomControlView.frame = CGRectMake(0.0f, self.videoView.bounds.size.height, width, 50.0f);
    }
}

- (void)showControlViewAniamted:(BOOL)animated{
    if (!self.isHideControlViews || self.viewMode == TTAVPlayerViewMuteMode){
        return;
    }
    CGFloat width = self.bounds.size.width;
    
    self.headControlView.frame = CGRectMake(0.0f, -50.0f, width, 50.0f);
    self.bottomControlView.frame = CGRectMake(0.0f, self.videoView.bounds.size.height, width, 50.0f);
    
    if (animated){
        self.isShowControlViewAnimated = YES;
        self.headControlView.hidden = NO;
        self.bottomControlView.hidden = NO;
        self.isHideControlViews = NO;
        
        [UIView animateWithDuration:0.5f animations:^{
            
            self.headControlView.bottom += 50.0f;
            self.bottomControlView.top -= 50.0f;
            
        } completion:^(BOOL finished) {
            
            self.headControlView.frame = CGRectMake(0.0f, 0.0f,width, 50.0f);
            self.bottomControlView.frame = CGRectMake(0.0f, self.videoView.bounds.size.height - 50.0f,width, 50.0f);
            
            self.isShowControlViewAnimated = NO;
            
        }];
    }else{
        self.headControlView.frame = CGRectMake(0.0f, 0.0f,width, 50.0f);
        self.bottomControlView.frame = CGRectMake(0.0f, self.videoView.bounds.size.height - 50.0f,width, 50.0f);
        
        self.headControlView.hidden = NO;
        self.bottomControlView.hidden = NO;
        self.isHideControlViews = NO;
        
    }
    [self toggleAutoHideOperationView];
}

- (void)toggleAutoHideOperationView{
    //特殊情况下，不自动隐藏操作栏
    if ([self specialCaseNOHideOperationView]){
        return;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showControlViewAutoDelayHandler) object:nil];
    [self performSelector:@selector(showControlViewAutoDelayHandler) withObject:nil afterDelay:5.0f];
}

- (BOOL)specialCaseNOHideOperationView{
    if (!self.loadingView.hidden){
        return YES;
    }
    return NO;
}

- (void)showControlViewAutoDelayHandler{
    [self hideControlViewAniamted:YES];
}

- (void)handleSwipe:(UIPanGestureRecognizer*)panGes{
    UIGestureRecognizerState state =  panGes.state;
    if (state == UIGestureRecognizerStateBegan){
        CGPoint startPoint = [panGes locationInView:self];
        if (startPoint.x <= self.bounds.size.width/2){
            self.part = TTAVPlayerViewPartLeft;
        }else{
            self.part = TTAVPlayerViewPartRight;
        }
        self.direction = TTPlayerSwipeDirectionNone;
    }else if(state == UIGestureRecognizerStateChanged){
        CGPoint transPoint = [panGes translationInView:self];
        switch (self.direction) {
            case TTPlayerSwipeDirectionNone:
                self.direction = [self directionWithTranslation:transPoint];
                self.isDragingSlider = NO;
                break;
            case TTPlayerSwipeDirectionHorizontal:
                //横向滑动需要底部进度条和提示View联动，所以这里也吃了一部分逻辑
                self.isDragingSlider = YES;
                if (transPoint.x > 0){
                    self.slider.value += 0.005;
                    
                    [self seek:self.slider];
                    [self.handleSwipeView swipeHorizontalToAdjustPlayProgress:self.totalTime * self.slider.value withTotalTime:self.totalTime isForward:YES];
                    
                }else if(transPoint.x < 0){
                    self.slider.value -= 0.005;
                    [self seek:self.slider];
                    [self.handleSwipeView swipeHorizontalToAdjustPlayProgress:self.totalTime * self.slider.value withTotalTime:self.totalTime isForward:NO];
                }
                break;
            case TTPlayerSwipeDirectionLeftVertical:
                [self.handleSwipeView swipeLeftVertical:transPoint];
                break;
            case TTPlayerSwipeDirectionRightVertical:
                [self.handleSwipeView swipeRightVertical:transPoint];
                break;
            default:
                break;
        }
        if (self.direction != TTPlayerSwipeDirectionNone){
            [panGes setTranslation:CGPointMake(0, 0) inView:self.handleSwipeView];
        }
    }else if (state == UIGestureRecognizerStateEnded){
        if (self.direction == TTPlayerSwipeDirectionHorizontal){
            [self resumeRefreshProgressSlider:self.slider];
        }
    }
}

- (TTAVPlayerSwipeDirection)directionWithTranslation:(CGPoint)translation{
    CGFloat transX = translation.x;
    CGFloat transY = translation.y;
    if (MAX(fabs(transX), fabs(transY)) < GesMinTranslationDistance){
        return TTPlayerSwipeDirectionNone;
    }
    if (fabs(transX) >= GesMinTranslationDistance){
        if (transY == 0 || (fabs(transX/transY) > GesMinTranslationRate)){
            return TTPlayerSwipeDirectionHorizontal;
        }else{
            return TTPlayerSwipeDirectionNone;
        }
    }else if (fabs(transY) >= GesMinTranslationDistance){
        if (transX == 0 || (fabs(transY/transX) > GesMinTranslationRate)){
            if (self.part == TTAVPlayerViewPartLeft){
                return TTPlayerSwipeDirectionLeftVertical;
            }else if (self.part == TTAVPlayerViewPartRight){
                return TTPlayerSwipeDirectionRightVertical;
            }
        }else{
            return TTPlayerSwipeDirectionNone;
        }
    }
    return TTPlayerSwipeDirectionNone;
}

#pragma mark - category getter

- (TTAVPlayerViewPart)part{
    NSNumber *partNum = objc_getAssociatedObject(self, &partAssoKey);
    return [partNum integerValue];
}

- (void)setPart:(TTAVPlayerViewPart)part{
    NSNumber *partNum = [NSNumber numberWithInteger:part];
    objc_setAssociatedObject(self, &partAssoKey, partNum, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TTAVPlayerSwipeDirection)direction{
    NSNumber *directionNum = objc_getAssociatedObject(self, &directionAssoKey);
    return (TTAVPlayerSwipeDirection)[directionNum integerValue];
}

- (void)setDirection:(TTAVPlayerSwipeDirection)direction{
    NSNumber *directionNum = [NSNumber numberWithInteger:direction];
    objc_setAssociatedObject(self, &directionAssoKey, directionNum, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end
