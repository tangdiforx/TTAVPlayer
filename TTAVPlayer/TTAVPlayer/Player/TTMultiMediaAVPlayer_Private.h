//
//  TTMultiMediaAVPlayer_Private.h
//  Multimedia
//
//  Created by 张祖权 on 2017/2/12.
//  Copyright © 2017年 Alipay. All rights reserved.
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
