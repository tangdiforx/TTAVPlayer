//
//  TTAVPlayerAdjustPlayProgressView.h
//  Multimedia
//
//  Created by 凡铁 on 17/2/10.
//  Copyright © 2017年 Alipay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTAVPlayerAdjustPlayProgressView : UIView

@property (nonatomic,assign) float totalTime;

@property (nonatomic,assign) float currentTime;

- (void)refreshUIWithPlayProgress:(Float64)currentTime withTotalTime:(Float64)totalTime isForward:(BOOL)isForward;

@end
