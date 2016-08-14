//
//  HBVideoChatViewController.m
//  视频聊天
//
//  Created by apple on 16/8/9.
//  Copyright © 2016年 yhb. All rights reserved.
//  一个可用的 rtmp://60.174.36.89:1935/live/aaa



#import <IJKMediaFramework/IJKMediaFramework.h>
#import "LFLiveKit.h"
#import "HBVideoChatViewController.h"
#import "HBVideoChatFoldButton.h"

#define screenWidth [UIScreen mainScreen].bounds.size.width

@interface HBVideoChatViewController ()<LFLiveSessionDelegate>
//当前区域网所在IP地址
@property (nonatomic,copy) NSString *ipAddress;
//我的房间号
@property (nonatomic,copy) NSString *myRoom;
//别人的房间号
@property (nonatomic,copy) NSString *othersRoom;
//ip后缀
@property (nonatomic, copy) NSString *suffix;
//大视图
@property (nonatomic,weak) UIView *bigView;
//小视图
@property (nonatomic,weak) UIView *smallView;
//播放器
@property (nonatomic,strong) IJKFFMoviePlayerController *player;
//推流会话
@property (nonatomic,strong) LFLiveSession *session;

@end

@implementation HBVideoChatViewController

- (instancetype)initWithIPAddress:(NSString *)ipAddress MyRoom:(NSString *)myRoom othersRoom:(NSString *)othersRoom{
    
    if (self = [self init]) {
        self.ipAddress = ipAddress;
        self.myRoom = myRoom;
        self.othersRoom = othersRoom;
        //suffix要根据服务器提供的字段名设定,如果搭建本地服务器是写rtmplive就是rtmplive
        self.suffix = @"rtmplive";
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //建立UI
    [self setupUI];
    //    录制端
    [self requesetAccessForVideo];
    [self requesetAccessForMedio];
    [self startLive];
    //将preview中的GPUImageView(显示摄像头内容的view)设置成与preView同大小(默认是与屏幕同尺寸)
    for (UIView *view in self.session.preView.subviews) {
        view.frame = self.session.preView.bounds;
    }
    //    播放端
    [self initPlayerObserver];
    [self.player play];
}

- (void)setupUI{
    [self setupView];
    [self setupButton];
}

//设置显示视图
- (void)setupView{
    UIView *bigView = [[UIView alloc] initWithFrame:self.view.bounds];
    bigView.backgroundColor = [UIColor greenColor];
    UIView *smallView = [[UIView alloc] initWithFrame:CGRectMake(100, 100, screenWidth/3, screenWidth/3)];
    smallView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:bigView];
    [self.view addSubview:smallView];
    self.bigView = bigView;
    self.smallView = smallView;
    //为smallView添加手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(exchangeView:)];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveSmallView:)];
    [self.smallView addGestureRecognizer:tap];
    [self.smallView addGestureRecognizer:pan];
}

//设置折叠按钮
- (void)setupButton{
    HBVideoChatFoldButton *button = [[HBVideoChatFoldButton alloc] initWithFrame:CGRectMake(10, 84, 30, 30) mainButtonBGImage:@"ordernormal" selectBGImage:@"orderselect" otherButtonsBGimages:@[@"cameraCH",@"beautifulCH"]];
    __weak typeof(self)weakSelf = self;
    button.ButtonClickBlock = ^void(UIButton *button) {
        switch (button.tag) {
            case 1:
                [weakSelf changeCamera];
                break;
            case 2:
                [weakSelf changeBeautifulMode];
                break;
            default:
                break;
        }
    };
    [self.view addSubview:button];
}

#pragma mark - 按钮响应
//改变前后美颜效果
- (void)changeBeautifulMode{
    self.session.beautyFace = !self.session.beautyFace;
}

//改变前后摄像头
- (void)changeCamera{
    AVCaptureDevicePosition devicePosition = self.session.captureDevicePosition;
    self.session.captureDevicePosition = (devicePosition == AVCaptureDevicePositionBack) ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
}

#pragma mark - 手势响应
//切换视图
- (void)exchangeView:(UITapGestureRecognizer *)tap{
    if (self.session.preView == self.smallView) {
        self.session.preView = self.bigView;
        self.player.view.frame = self.smallView.bounds;
        [self.player.view removeFromSuperview];
        [self.smallView addSubview:self.player.view];
    } else {
        self.session.preView = self.smallView;
        self.player.view.frame = self.bigView.bounds;
        [self.player.view removeFromSuperview];
        [self.bigView addSubview:self.player.view];
    }
    
}
//移动小窗口
- (void)moveSmallView:(UIPanGestureRecognizer *)pan{
    self.smallView.center = [pan locationInView:self.view];
}



#pragma mark - 播放器 设置播放器播放通知监听
- (void)initPlayerObserver{
    //监听网络状态改变
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadStateDidChange:) name:IJKMPMoviePlayerLoadStateDidChangeNotification object:self.player];
    //监听播放网络状态改变
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playStateDidChange:) name:IJKMPMoviePlayerPlaybackStateDidChangeNotification object:self.player];
}

#pragma mark - 播放器 通知响应
//网络状态改变通知响应
- (void)loadStateDidChange:(NSNotification *)notification{
    IJKMPMovieLoadState loadState = self.player.loadState;
    if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
        NSLog(@"LoadStateDidChange: 可以开始播放的状态: %d\n",(int)loadState);
    }else if ((loadState & IJKMPMovieLoadStateStalled) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStateStalled: %d\n", (int)loadState);
    } else {
        NSLog(@"loadStateDidChange: ???: %d\n", (int)loadState);
    }
}
//播放状态改变通知响应
- (void)playStateDidChange:(NSNotification *)notification{
    switch (_player.playbackState) {
            
        case IJKMPMoviePlaybackStateStopped:
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: stoped", (int)_player.playbackState);
            break;
            
        case IJKMPMoviePlaybackStatePlaying:
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: playing", (int)_player.playbackState);
            break;
            
        case IJKMPMoviePlaybackStatePaused:
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: paused", (int)_player.playbackState);
            break;
            
        case IJKMPMoviePlaybackStateInterrupted:
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: interrupted", (int)_player.playbackState);
            break;
            
        case IJKMPMoviePlaybackStateSeekingForward:
        case IJKMPMoviePlaybackStateSeekingBackward: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: seeking", (int)_player.playbackState);
            break;
        }
            
        default: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: unknown", (int)_player.playbackState);
            break;
        }
    }
}

#pragma mark - 推流端 开始/停止推流方法
- (void)startLive{
    //RTMP要设置推流地址
    LFLiveStreamInfo *streamInfo = [LFLiveStreamInfo new];
    streamInfo.url = [NSString stringWithFormat:@"rtmp://%@:1935/%@/%@",self.ipAddress,self.suffix,self.myRoom];
    [self.session startLive:streamInfo];
}

- (void)stopLive{
    [self.session stopLive];
}

#pragma mark - 推流段-请求设备授权
/**
 *  请求摄像头资源
 */
- (void)requesetAccessForVideo{
    __weak typeof(self) weakSelf = self;
    //判断授权状态
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusNotDetermined:{
            //发起授权请求
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //运行会话
                        [weakSelf.session setRunning:YES];
                    });
                }
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized:{
            //已授权则继续
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.session setRunning:YES];
            });
            break;
        }
        default:
            break;
    }
}

/**
 *  请求音频资源
 */
- (void)requesetAccessForMedio{
    __weak typeof(self) weakSelf = self;
    //判断授权状态
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusNotDetermined:{
            //发起授权请求
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //运行会话
                        [weakSelf.session setRunning:YES];
                    });
                }
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized:{
            //已授权则继续
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.session setRunning:YES];
            });
            break;
        }
        default:
            break;
    }
    
}

#pragma mark - LFLiveSessionDelegate
//状态改变回调
- (void)liveSession:(nullable LFLiveSession *)session liveStateDidChange:(LFLiveState)state{
    //    /// 准备
    //    LFLiveReady = 0,
    //    /// 连接中
    //    LFLivePending = 1,
    //    /// 已连接
    //    LFLiveStart = 2,
    //    /// 已断开
    //    LFLiveStop = 3,
    //    /// 连接出错
    //    LFLiveError = 4
}
//调试回调
- (void)liveSession:(nullable LFLiveSession *)session debugInfo:(nullable LFLiveDebug *)debugInfo{
    NSLog(@"调试信息");
}
//连接错误回调
- (void)liveSession:(nullable LFLiveSession *)session errorCode:(LFLiveSocketErrorCode)errorCode{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Warning" message:@"连接错误,请检查IP地址后重试" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"sure" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [alert addAction:sure];
    [self presentViewController:alert animated:YES completion:nil];
    
}

#pragma mark - 懒加载
- (LFLiveSession *)session{
    if (_session == nil) {
        //初始化session要传入音频配置和视频配置
        //音频的默认配置为:采样率44.1 双声道
        //视频默认分辨率为360 * 640
        _session = [[LFLiveSession alloc] initWithAudioConfiguration:[LFLiveAudioConfiguration defaultConfiguration] videoConfiguration:[LFLiveVideoConfiguration defaultConfigurationForQuality:LFLiveVideoQuality_Low1] ];
        //设置返回的视频显示在哪个view上
        _session.preView = self.smallView;
        _session.delegate = self;
        //是否输出调试信息
        _session.showDebugInfo = NO;
    }
    return _session;
}

-(IJKFFMoviePlayerController *)player{
    if (_player == nil) {
        IJKFFOptions *options = [IJKFFOptions optionsByDefault];
        _player = [[IJKFFMoviePlayerController alloc] initWithContentURLString:[NSString stringWithFormat:@"rtmp://%@:1935/%@/%@",self.ipAddress,self.suffix,self.othersRoom] withOptions:options];
        //设置填充模式
        _player.scalingMode = IJKMPMovieScalingModeAspectFill;
        //设置播放视图
        _player.view.frame = self.bigView.bounds;
        [self.bigView addSubview:_player.view];
        //设置自动播放
        _player.shouldAutoplay = YES;
        
        [_player prepareToPlay];
    }
    return _player;
}


#pragma mark - dealloc
-(void)dealloc{
    _session.delegate = nil;
    NSLog(@"销毁");
}

@end
