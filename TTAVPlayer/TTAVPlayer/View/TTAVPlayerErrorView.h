//
//  TTAVPlayerErrorView.h
//  Multimedia
//
//  Created by 凡铁 on 17/2/2.
//  Copyright © 2017年 Alipay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTAVPlayerErrorView : UIView

@property (nonatomic, copy) void(^retryBlock)();

@property (nonatomic, copy) void(^closeBlock)();

- (void)setTitle:(NSString *)title;

@end
