

//
//  YhsHandleView.m
//  CustomPlayer
//
//  Created by 熊俊 on 2019/10/22.
//  Copyright © 2019 熊俊. All rights reserved.
//

#import "YhsHandleView.h"
#import "UIView+Attribute.h"

@interface YhsHandleView()

@property (nonatomic,strong) UIButton *playBtn;
@property (nonatomic,strong) UIProgressView *progressView;
@property (nonatomic,strong) UIButton *fullScreenBtn;
@property (nonatomic,strong) UILabel *currentTimeLab;
@property (nonatomic,strong) UILabel *totalTimeLab;
@property (nonatomic,strong) UISlider *slider;

@end

@implementation YhsHandleView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        //全屏按钮
        self.fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.fullScreenBtn setImage:[UIImage imageNamed:@"quanping"] forState:UIControlStateNormal];
        [self.fullScreenBtn addTarget:self action:@selector(fullScreen) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.fullScreenBtn];
        
        //播放暂停按钮
        self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.playBtn setImage:[UIImage imageNamed:@"iconstop"] forState:UIControlStateNormal];
        [self.playBtn setImage:[UIImage imageNamed:@"zanting"] forState:UIControlStateSelected];
        [self.playBtn addTarget:self action:@selector(playClick:) forControlEvents:UIControlEventTouchUpInside];
        self.playBtn.selected = NO;
        [self addSubview:self.playBtn];
        
        self.progressView = [UIProgressView new];
        self.progressView.trackTintColor = [UIColor colorWithRed:77/255.0 green:74/255.0 blue:72/255.0 alpha:1];
        self.progressView.tintColor = [UIColor colorWithRed:126/255.0 green:118/255.0 blue:116/255.0 alpha:1];
        self.progressView.progress = 0;
        [self addSubview:self.progressView];
        
        
        self.slider = [UISlider new];
        self.slider.minimumTrackTintColor = [UIColor whiteColor];
        self.slider.thumbTintColor = [UIColor whiteColor];
        self.slider.maximumTrackTintColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        self.slider.minimumValue = 0;
        self.slider.continuous = YES;
        [self addSubview:self.slider];
        [self.slider setThumbImage:[[UIImage imageNamed:@"shixinyuanxing"] resizableImageWithCapInsets:UIEdgeInsetsZero] forState:UIControlStateNormal];
        [self.slider setThumbImage:[[UIImage imageNamed:@"shixinyuanxing"] resizableImageWithCapInsets:UIEdgeInsetsZero] forState:UIControlStateHighlighted];
        // slider开始滑动
        [self.slider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
        // slider滑动中事件
        [self.slider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        // slider结束滑动事件
        [self.slider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];

        self.currentTimeLab = [UILabel new];
        self.currentTimeLab.font = [UIFont systemFontOfSize:12];
        self.currentTimeLab.textColor = [UIColor whiteColor];
//        self.currentTimeLab.alpha = 0;
        self.currentTimeLab.numberOfLines = 0;
        self.currentTimeLab.text = @"00:00";

        self.currentTimeLab.contentMode = NSTextAlignmentCenter;
        [self addSubview:self.currentTimeLab];
        
        self.totalTimeLab = [UILabel new];
        self.totalTimeLab.font = [UIFont systemFontOfSize:12];
        self.totalTimeLab.textColor = [UIColor whiteColor];
        self.totalTimeLab.numberOfLines = 0;
        self.totalTimeLab.text = @"--:--";
        self.totalTimeLab.contentMode = NSTextAlignmentCenter;
        [self addSubview:self.totalTimeLab];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleClick)];
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:tap];
        self.alpha = 0;
        
        __weak YhsHandleView *weakSelf = self;
        self.endPlayBlock = ^{
            weakSelf.playBtn.selected = YES;
        };
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView* result = [super hitTest:point withEvent:event];
    if (result != self) {
        if ((point.y >= self.height-5) &&
            (point.y < self.height-40) &&
            (point.x >= 0 && point.x < CGRectGetWidth(self.bounds))) {
            result = self;
        }
    }
    return result;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    BOOL result = [super pointInside:point withEvent:event];
    if (!result) {
        //同理,如果不在slider范围类,扩充响应范围
        if ((point.y >= self.height-5) &&
            (point.y < self.height-40) &&
            (point.x >= 0 && point.x < CGRectGetWidth(self.bounds))) {
            //在扩充范围内,返回yes
            result = YES;
        }
    }
    //否则返回父类的结果
    return result;
}

- (void)progressSliderTouchBegan:(UISlider *)slider{
    self.touchProcess(1,self.slider.value);
}

- (void)progressSliderValueChanged:(UISlider *)slider{
    self.touchProcess(2,self.slider.value);
}

- (void)progressSliderTouchEnded:(UISlider *)slider{
    self.touchProcess(3,self.slider.value);
}

- (void)setIsDisappear:(BOOL)isDisappear{
    _isDisappear = isDisappear;
}

- (void)setTotalTimeString:(NSString *)totalTimeString{
    _totalTimeString = totalTimeString;
    _totalTimeLab.text = totalTimeString;
}

- (void)setCurrentTimeString:(NSString *)currentTimeString{
    _currentTimeString = currentTimeString;
    _currentTimeLab.text = currentTimeString;
}

-(void)setProgress:(CGFloat)progress{
    _progress = progress;
//    self.progressView.progress = progress;
    self.slider.value = progress;
}

- (void)setLoadProgress:(CGFloat)loadProgress{
    _loadProgress = loadProgress;
    self.progressView.progress = loadProgress;
}

- (void)handleClick{
    [UIView animateWithDuration:0.4 animations:^{
        self.alpha = 1.0;
    }];
}

- (void)fullScreen{
    if (_delegate && [_delegate respondsToSelector:@selector(fullScreen)]) {
        [_delegate fullScreen];
    }
}

- (void)playClick:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (_delegate && [_delegate respondsToSelector:@selector(playClick:)]) {
        [_delegate playClick:sender];
    }
}

- (void)sliderTouchUpInSide:(UISlider *)slider{
    NSLog(@"滑动结束touch");
}

// 实现方法
- (void)sliderValueChanged:(UISlider*)slider forEvent:(UIEvent*)event {
    UITouch*touchEvent = [[event allTouches] anyObject];
    switch (touchEvent.phase) {
        case UITouchPhaseBegan:
        {
            NSLog(@"滑动开始");
            self.touchProcess(1,self.slider.value);
        }
            break;
        case UITouchPhaseMoved:
        {
            NSLog(@"滑动中");
            self.touchProcess(2,self.slider.value);
        }
            break;
        case UITouchPhaseEnded:
        {
            NSLog(@"滑动结束");
            self.touchProcess(3,self.slider.value);
        }
            break;
        default:
            break;
    }
}


- (void)layoutSubviews{
    [super layoutSubviews];
    if (!_isDisappear) {
        self.totalTimeLab.size = self.currentTimeLab.size = CGSizeMake(40, 20);
        self.currentTimeLab.origin = CGPointMake(15, self.height-30);
        self.fullScreenBtn.frame = CGRectMake(self.width-20-10, self.currentTimeLab.top, 20, 20);
        self.totalTimeLab.origin = CGPointMake(self.width-self.totalTimeLab.width-20-10-3, self.currentTimeLab.top);
        NSLog(@"totalTimeLab==%f",self.totalTimeLab.origin.x);
        self.progressView.frame = CGRectMake(self.currentTimeLab.right, 20, self.width-self.currentTimeLab.width-self.self.totalTimeLab.width-self.fullScreenBtn.width-25-3-3-5, 2);
        self.slider.frame = CGRectMake(self.progressView.left-2, self.progressView.top, self.progressView.width+2+2, self.slider.height);
        self.progressView.centerY = self.slider.centerY = self.totalTimeLab.centerY = self.fullScreenBtn.centerY = self.currentTimeLab.centerY;
        self.playBtn.size = CGSizeMake(25, 25);
        self.playBtn.center = self.center;
    }
}

- (void)dealloc
{
    NSLog(@"Handle销毁了");
}




@end
