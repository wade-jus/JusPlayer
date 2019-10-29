//
//  YhsADPlayer.m
//  CustomPlayer
//
//  Created by 熊俊 on 2019/10/21.
//  Copyright © 2019 熊俊. All rights reserved.
//

#import "YhsADPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "YhsADFullScreenViewController.h"
#import "YhsHandleView.h"
#import "WeakObject.h"

@interface YhsADPlayer()<HandleDelegate,UIGestureRecognizerDelegate>

@property (nonatomic,weak) AVPlayer *player;
@property (nonatomic,weak) AVPlayerItem *playerItem;
@property (nonatomic,weak) AVPlayerLayer *playerLayer;
@property (nonatomic,strong) YhsHandleView *handleView;

@property (nonatomic,assign) BOOL isFullScreen;

@property (nonatomic,assign) CGRect originalRect;

@property (nonatomic,weak) NSTimer *timer;

@property (nonatomic,weak) NSTimer *progressTimer;

@property (nonatomic,strong) UISlider *volumeViewSlider; //系统音量

@property (nonatomic,assign) CGFloat totalTime;

@property (nonatomic,assign) BOOL isShowHandle;

@property (nonatomic,assign) BOOL isDragged;  //是否正在拖动

@property (nonatomic,assign) BOOL isPlay;    //是否正在播放

@property (nonatomic,assign) BOOL isLight;   //是否是亮度调节

@property (nonatomic,assign) BOOL isVertical; //垂直方向手势

@property (nonatomic,assign) NSInteger showTime;

@end

@implementation YhsADPlayer

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupPayer];
        [self setupPlayerState];
    }
    return self;
}

- (void)setupPayer{
    self.isFullScreen = NO;
    self.isShowHandle = NO;
    self.isDragged = NO;
    self.showTime = 0;
    
    [self configureVolume]; //获取系统音量Slider
    
    NSURL *playUrl = [NSURL URLWithString:self.playUrl];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:playUrl];
    _playerItem = playerItem;
    //如果要切换视频需要调AVPlayer的replaceCurrentItemWithPlayerItem:方法
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    _player = player;
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.backgroundColor = [UIColor redColor];
    playerLayer.frame = self.bounds;
    [self.layer addSublayer:playerLayer];
    playerLayer.backgroundColor = [UIColor blackColor].CGColor;
    _playerLayer = playerLayer;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(videoClick)];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:tap];
    
    self.handleView = [YhsHandleView new];
    self.handleView.userInteractionEnabled = YES;
    self.handleView.delegate = self;
    self.handleView.alpha = 0;
    [self addSubview:self.handleView];
    [self bringSubviewToFront:self.handleView];
    
    __weak YhsADPlayer *weakSelf = self;
    self.handleView.touchProcess = ^(NSInteger state,CGFloat value) {
        switch (state) {
            case 1:
            {
                weakSelf.showTime = 0;
                weakSelf.isDragged = YES;
                NSLog(@"开始滑动");
            }
                break;
            case 2:
            {
                NSLog(@"滑动中");
                 [weakSelf.player pause];
            }
                break;
            case 3:
            {
                NSLog(@"滑动结束");
                weakSelf.showTime = 0;
                CGFloat progress = value*self.totalTime;
                NSInteger dragedSeconds = floorf(progress);
                CMTime dragedCMTime = CMTimeMake(dragedSeconds, 1);
                weakSelf.handleView.totalTimeString = [weakSelf handleTimeToString:self.totalTime - CMTimeGetSeconds(dragedCMTime)];
                weakSelf.handleView.currentTimeString = [weakSelf handleTimeToString:CMTimeGetSeconds(dragedCMTime)];
                [weakSelf.player seekToTime:dragedCMTime];
                if (weakSelf.isPlay) [weakSelf.player play];
                weakSelf.isDragged = NO;
            }
                break;
            default:
                break;
        }
    };
    
}

- (void)videoClick{
    self.isShowHandle = YES;
    [UIView animateWithDuration:0.4 animations:^{
        self.handleView.alpha = 1.0;
    }];
}

- (void)hiddenHandleAnimation{
    self.isShowHandle = NO;
    [UIView animateWithDuration:0.4 animations:^{
        self.handleView.alpha = 0;
    }];
}

#pragma mark -HanldeDelegate
- (void)playClick:(UIButton *)sender{
    self.showTime = 0;
    if ([self.handleView.totalTimeString isEqualToString:@"00:00"]) {
        [self toPlay];
        return;
    }
    if (sender.selected) {
        [self.player pause];
        self.isPlay = NO;
    }else{
        [self.player play];
        self.isPlay = YES;
    }
}

//重新播放
- (void)toPlay{
    self.isPlay = YES;
    CGFloat progress = 0;
    NSInteger dragedSeconds = floorf(progress);
    CMTime dragedCMTime = CMTimeMake(dragedSeconds, 1);
    self.handleView.progress = 0;
    self.handleView.totalTimeString = [self handleTimeToString:self.totalTime];
    self.handleView.currentTimeString = @"00:00";
    [self.player seekToTime:dragedCMTime];
    [self.player play];
    [self initTimer];
    [self initProgressTimer];
}

- (void)fullScreen{
    NSLog(@"全屏");
    self.showTime = 0;
    if (!self.isFullScreen) {
        self.isFullScreen = YES;
        UIWindow *window = [UIApplication sharedApplication].delegate.window;
        [window addSubview:self];
        
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationLandscapeRight] forKey:@"orientation"];
        self.frame = CGRectMake(0, 0, MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height), MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height));
    }else{
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
        self.isFullScreen = NO;
//        CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
//        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
//        [UIView animateWithDuration:duration animations:^{
//                self.transform = CGAffineTransformMakeRotation(0);
//        }completion:^(BOOL finished) {
//
//        }];
        self.frame = CGRectMake(0, 88, MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height), 232.875);
    }
}

- (CABasicAnimation *)transformAnimation{
    CABasicAnimation *transformAnimate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    transformAnimate.removedOnCompletion = NO;
    transformAnimate.duration = 0.25;
    transformAnimate.fillMode = kCAFillModeForwards;
    transformAnimate.toValue = @(M_PI*-0.5);
    
    return transformAnimate;
}

- (void)setPlayUrl:(NSString *)playUrl{
    _playUrl = playUrl;
    [self setupPayer];
    [self setupPlayerState];
    [self initTimer];
}

- (void)initTimer{
    if (_progressTimer) {
        [self invalidataTimer];
    }
    WeakObject *target = [WeakObject proxyWeakObject:self];
    NSTimer *timer = [NSTimer timerWithTimeInterval:0.1f target:target selector:@selector(updateProgress) userInfo:nil repeats:YES];
    _timer = timer;
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)initProgressTimer{
    if (_progressTimer) {
        [self invalidataProgressTimer];
    }
    WeakObject *target = [WeakObject proxyWeakObject:self];
    NSTimer *progressTimer = [NSTimer timerWithTimeInterval:1.0f target:target selector:@selector(updateTimeValue) userInfo:nil repeats:YES];
    _progressTimer = progressTimer;
    [[NSRunLoop mainRunLoop] addTimer:_progressTimer forMode:NSRunLoopCommonModes];
}


- (void)setupPlayerState{
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([object isKindOfClass:[AVPlayerItem class]]) {
        if ([keyPath isEqualToString:@"status"]) {
            switch (_playerItem.status) {
                case AVPlayerItemStatusReadyToPlay:
                {
                    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panDirection:)];
                    panRecognizer.delegate                = self;
                    [panRecognizer setMaximumNumberOfTouches:1];
                    [panRecognizer setDelaysTouchesBegan:YES];
                    [panRecognizer setDelaysTouchesEnded:YES];
                    [panRecognizer setCancelsTouchesInView:YES];
                    [self addGestureRecognizer:panRecognizer];
                    self.totalTime = CMTimeGetSeconds(self.playerItem.duration);
                    self.handleView.totalTimeString = [self handleTimeToString:self.totalTime];
                }
                    break;
                case AVPlayerItemStatusFailed:
                {
                    
                }
                    break;
                case AVPlayerItemStatusUnknown:
                {
                    
                }
                    break;
                default:
                    break;
            }
        }
        if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
            //进度
            NSTimeInterval timeInterval = [self availableDuration];
            NSLog(@"timeInterval===%f",timeInterval);
            CMTime duration             = self.playerItem.duration;
//            CGFloat totalDuration       = CMTimeGetSeconds(duration);
            if (timeInterval/self.totalTime > self.handleView.loadProgress){
               self.handleView.loadProgress = timeInterval/self.totalTime;
            }
        }
        if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
            [self performSelector:@selector(play) withObject:@"buffering" afterDelay:3];
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    //如果手势是触摸的UISlider滑块触发的，侧滑返回手势就不响应
    if ([touch.view isKindOfClass:[UISlider class]]) {
        return NO;
    }
    return YES;
}

- (void)panDirection:(UIPanGestureRecognizer *)pan{
    CGPoint locationPoint = [pan locationInView:self];
    CGPoint veloctyPoint = [pan velocityInView:self];
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        {
            CGFloat x = fabs(veloctyPoint.x);
            CGFloat y = fabs(veloctyPoint.y);
            if (x > y) { //水平
                self.isVertical = NO;
            }else if (x < y){//垂直移动
                self.isVertical = YES;
                if (locationPoint.x > self.bounds.size.width / 2) {
                    //调节声音
                    self.isLight = NO;
                }else {
                    // 状态改为显示亮度调节
                    self.isLight = YES;
                }
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            [self setVolumeAndLight:veloctyPoint.y];
        }
            break;
        case UIGestureRecognizerStateEnded:
            break;
        default:
            break;
    }
}

- (void)setVolumeAndLight:(CGFloat)value{
    self.isLight?([UIScreen mainScreen].brightness -= value / 10000):(self.volumeViewSlider.value -= value/10000);
}

//获取系统音量UISlider,以便重新赋值音量
- (void)configureVolume {
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    _volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            _volumeViewSlider = (UISlider *)view;
            break;
        }
    }
}

- (void)play{
    [self.player play];
    self.isPlay = YES;
    CGRect frame = self.frame;
    frame.size.height = self.playerLayer.frame.size.height;
    self.frame = frame;
    [self initProgressTimer];
}

- (void)updateProgress{
    if (self.handleView.progress == 1) {
        [self invalidataTimer];
        return;
    }
    if (_totalTime > 0 && !self.isDragged) {
        self.handleView.progress = CMTimeGetSeconds(self.playerItem.currentTime)/self.totalTime;
    }
}

- (void)updateTimeValue{
    if (self.showTime == 4) {
        self.showTime = 0;
        [self hiddenHandleAnimation];
    }
    if (self.isShowHandle) {
        self.showTime ++;
    }
    
    if ([self.handleView.totalTimeString isEqualToString:@"00:00"]) {
//        [self invalidataProgressTimer];
        [self videoClick];
        self.handleView.endPlayBlock();
        self.isPlay = NO;
        return;
    }
    if (_totalTime > 0 && !self.isDragged) {
         self.handleView.totalTimeString = [self handleTimeToString:self.totalTime - CMTimeGetSeconds(self.playerItem.currentTime)];
//        NSLog(@"totalTimeString === %@",self.handleView.totalTimeString);
        self.handleView.currentTimeString = [self handleTimeToString:CMTimeGetSeconds(self.playerItem.currentTime)];
    }
}

#pragma mark - UIGestureRecognizerDelegate
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
//    if ([self.handleView.subviews containsObject:gestureRecognizer.view]) {
//        return NO;
//    }
//    return YES;
//}

- (NSString *)handleTimeToString:(CGFloat)totalTime{
    int pTime = (int)totalTime;
//    int hour = pTime / 3600;
    int minutes = (pTime / 60) % 60 ;
    int second = pTime % 60 ;
    
//    NSString * time = [NSString  stringWithFormat:@"%02d:%02d:%02d" ,hour,minutes,second];
     NSString * time = [NSString  stringWithFormat:@"%02d:%02d" ,minutes,second];
    return time;
}

- (void)invalidataTimer{
    [_timer invalidate];
    _timer = nil;
}

- (void)invalidataProgressTimer{
    [_progressTimer invalidate];
    _progressTimer = nil;
}

- (NSTimeInterval)availableDuration{
    NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges];
    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds        = CMTimeGetSeconds(timeRange.start);
    float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result     = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.playerLayer.frame = self.bounds;
    self.handleView.frame = self.bounds;
    if(!self.isFullScreen){
        self.originalRect = self.bounds;
    }
    
}

- (void)dealloc
{
    NSLog(@"我销毁了");
    _timer = nil;
    _progressTimer = nil;
}

@end
