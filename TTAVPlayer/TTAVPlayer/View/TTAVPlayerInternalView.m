//
//  TTAVPlayerInternalView.m
//  Multimedia
//
//  Created by 凡铁 on 17/2/5.
//  Copyright © 2017年 Alipay. All rights reserved.
//

#import "TTAVPlayerInternalView.h"
#import <AVFoundation/AVFoundation.h>

@interface TTAVPlayerInternalView()



@end

@implementation TTAVPlayerInternalView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

@end
