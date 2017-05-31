//
//  TTAVPlayerSwipeHandlerView.h
//  Multimedia
//
//  Created by dylan.tang on 17/2/10.
//  Copyright © 2017年 dylan.tang. All rights reserved.
//

#import <UIKit/UIKit.h>

#define GesMinTranslationDistance  5.0f//最小移动距离
#define GesMinTranslationRate  3.0 //最小x/y的比例

typedef NS_ENUM(NSInteger,TTAVPlayerSwipeDirection){
    TTPlayerSwipeDirectionNone = 0,
    TTPlayerSwipeDirectionHorizontal = 1,
    TTPlayerSwipeDirectionLeftVertical = 2,
    TTPlayerSwipeDirectionRightVertical = 3
};

typedef NS_ENUM(NSInteger,TTAVPlayerViewPart){
    TTAVPlayerViewPartLeft = 0,
    TTAVPlayerViewPartRight = 1
};

@interface TTAVPlayerSwipeHandlerView : UIView

- (void)swipeLeftVertical:(CGPoint)translation;

- (void)swipeRightVertical:(CGPoint)translation;

- (void)swipeHorizontalToAdjustPlayProgress:(Float64)currentTime withTotalTime:(Float64)totalTime isForward:(BOOL)isForward;

@end
