//
//  TTAVPlayerErrorView.h
//  Multimedia
//
//  Created by dylan.tang on 17/2/2.
//  Copyright © 2017年 dylan.tang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTAVPlayerErrorView : UIView

@property (nonatomic, copy) void(^retryBlock)();

@property (nonatomic, copy) void(^closeBlock)();

- (void)setTitle:(NSString *)title;

@end
