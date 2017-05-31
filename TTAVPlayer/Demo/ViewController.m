//
//  ViewController.m
//  TTavplayer
//
//  Created by dylan.tang on 17/3/23.
//  Copyright © 2017年 dylan.tang. All rights reserved.
//

#import "ViewController.h"
#import "TTAVPlayer.h"

const static float screenRate = 0.56;

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *demoTableView;

@property (nonatomic,strong) NSArray *demoInfoArray;

@property (nonatomic,strong) TTAVPlayerView *playerView;

@property (nonatomic,strong) TTAVPlayerVideoInfo *videoInfo;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initParams];
    [self initUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initParams{
    _demoInfoArray = @[@"普通模式",@"竖屏模式",@"静音模式",@"自定义模式"];

    _videoInfo = [[TTAVPlayerVideoInfo alloc]init];
    _videoInfo.videoUrl = @"https://cloud.video.taobao.com/play/u/2359172108/p/1/e/6/t/1/53317456.mp4";
    _videoInfo.videoTitle = @"视频测试";
}

- (void)initUI{
    _demoTableView = [[UITableView alloc]initWithFrame:self.view.bounds];
    _demoTableView.delegate = self;
    _demoTableView.dataSource = self;
    _demoTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_demoTableView];
}

#pragma mark - UITableView DataSource && Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _demoInfoArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = [_demoInfoArray objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_playerView.superview){
        [_playerView removeFromSuperview];
        _playerView = nil;
    }
    
    CGFloat width,height;
    
    width = [UIApplication sharedApplication].keyWindow.bounds.size.width;
    height =[UIApplication sharedApplication].keyWindow.bounds.size.height;
    if (indexPath.row == 0){
        
        height = width * screenRate;
        _playerView = [[TTAVPlayerView alloc]initWithFrame:CGRectMake(0.0f, (self.view.bounds.size.height - height)/2, width, height) withVideoInfo:_videoInfo withViewMode:TTAVPlayerViewNormalMode];
        
    }else if (indexPath.row == 1){
        
        _playerView = [[TTAVPlayerView alloc]initWithFrame:CGRectMake(0.0f, (self.view.bounds.size.height - height)/2, width, height) withVideoInfo:_videoInfo withViewMode:TTAVPlayerViewPortraitMode];
        [[UIApplication sharedApplication].keyWindow addSubview:_playerView];
        [_playerView play];
        return;
    }else if (indexPath.row == 2){
        
        height = width * screenRate;
        _playerView = [[TTAVPlayerView alloc]initWithFrame:CGRectMake(0.0f, (self.view.bounds.size.height - height)/2, width, height) withVideoInfo:_videoInfo withViewMode:TTAVPlayerViewMuteMode];
        
    }else if (indexPath.row == 3){
        height = width * screenRate;
        _playerView = [[TTAVPlayerView alloc]initWithFrame:CGRectMake(0.0f, (self.view.bounds.size.height - height)/2, width, height) withVideoInfo:_videoInfo withViewMode:TTAVPlayerViewUserDefineMode];
    }
    
    [self.view addSubview:_playerView];
    [_playerView play];

}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

@end
