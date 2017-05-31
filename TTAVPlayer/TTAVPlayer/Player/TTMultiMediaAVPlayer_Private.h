//
//  TTMultiMediaAVPlayer_Private.h
//  Multimedia
//
//  Created by zuquan.zhang on 2017/2/12.
//  Copyright © 2017年 dylan.tang. All rights reserved.
//

#ifndef TTMultiMediaAVPlayer_Private_h
#define TTMultiMediaAVPlayer_Private_h

@interface TTMultiMediaAVPlayer ()
@property (nonatomic, strong) id timeObserver;
@property (nonatomic, assign) TTMultiMediaAVPlayerStatus playerStatus;

@property (nonatomic, assign) Float64 loadedTime;
//- (Float64)availableDuration;
-(void)statusWaiting;
-(void)playerError:(NSError*)error;
-(BOOL)checkAvailable;
@end

#endif /* TTMultiMediaAVPlayer_Private_h */
