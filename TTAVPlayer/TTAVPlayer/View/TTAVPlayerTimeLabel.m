//
//  TTAVPlayerTimeLabel.m
//  Multimedia
//
//  Created by dylan.tang on 17/2/6.
//  Copyright © 2017年 dylan.tang. All rights reserved.
//

#import "TTAVPlayerTimeLabel.h"

@interface TTAVPlayerTimeLabel()

@property (nonatomic,strong) NSDateFormatter *dateFormatter;

@end

@implementation TTAVPlayerTimeLabel

- (instancetype)init{
    self = [super init];
    if (self){
        self.font = [UIFont systemFontOfSize:13.0f];
        self.textColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setTime:(CGFloat)currentTime{
    [self.dateFormatter setDateFormat:(currentTime >= 3600 ? @"HH:mm:ss" : @"mm:ss")];
    NSDate *currentDate   = [NSDate dateWithTimeIntervalSince1970:currentTime];
    [self setText:[self.dateFormatter stringFromDate:currentDate]];
}

- (NSDateFormatter*)dateFormatter{
    if (!_dateFormatter){
        _dateFormatter = [[NSDateFormatter alloc]init];
        [_dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    }
    return _dateFormatter;
}

@end
