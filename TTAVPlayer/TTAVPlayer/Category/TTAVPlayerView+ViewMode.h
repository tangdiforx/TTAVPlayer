//
//  TTAVPlayerView+ViewMode.h
//  Multimedia
//
//  Created by 凡铁 on 17/2/5.
//  Copyright © 2017年 Alipay. All rights reserved.
//

#import "TTAVPlayerView.h"

@interface TTAVPlayerView (ViewMode)

- (void)setupUIWithViewMode:(TTAVPlayerViewMode)mode;

- (void)changeToMuteMode;

- (void)changeToNormalMode;

- (void)changeToPortraitMode;

- (void)changeToLandScapeMode;

//从横屏回去原本的viewMode
- (void)backToOriginViewMode;

// show hide control view

- (void)showControlViewAniamted:(BOOL)animated;

- (void)hideControlViewAniamted:(BOOL)animated;

- (void)toggleAutoHideOperationView;

@end
