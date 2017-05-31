//
//  TTMultiMediaAVPlayer+Observer.h
//  Multimedia
//
//  Created by zuquan.zhang on 2017/2/10.
//  Copyright © 2017年 dylan.tang. All rights reserved.
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
