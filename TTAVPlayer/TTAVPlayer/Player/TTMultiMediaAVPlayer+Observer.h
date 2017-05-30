//
//  TTMultiMediaAVPlayer+Observer.h
//  Multimedia
//
//  Created by 张祖权 on 2017/2/10.
//  Copyright © 2017年 Alipay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTMultiMediaAVPlayer.h"

@interface TTMultiMediaAVPlayer (Observer) 
- (void)setupPlayerObserver;

- (void)cleanPlayerObserver;
- (void)clean;

- (void)playerDidFinishPlaying:(NSNotification *)notification;
- (void)playerFailedToPlayToEnd:(NSNotification *)notification;
- (void)playerStalled:(NSNotification *)notification;
@end
