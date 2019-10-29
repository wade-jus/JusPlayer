//
//  ViewController.m
//  CustomPlayer
//
//  Created by 熊俊 on 2019/10/21.
//  Copyright © 2019 熊俊. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "YhsADPlayer.h"
#import "YhsADFullScreenViewController.h"
#import <KissXML/KissXML.h>

@interface ViewController ()

@property (nonatomic,strong) YhsADPlayer *adPlayer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.adPlayer = [YhsADPlayer new];
    self.adPlayer.frame = CGRectMake(0, 88, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width*9/16);
    //http://vfx.mtime.cn/Video/2019/02/04/mp4/190204084208765161.mp4
    //https://v-cdn.zjol.com.cn/276990.mp4
    //http://vfx.mtime.cn/Video/2019/02/04/mp4/190204084208765161.mp4
    self.adPlayer.playUrl = @"https://v-cdn.zjol.com.cn/276990.mp4";
    //    self.adPlayer.center = self.view.center;
    self.adPlayer.viewController = self;
    [self.view addSubview:_adPlayer];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"present" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, 0, 100, 30);
    btn.center = self.view.center;
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(presentToSecond) forControlEvents:UIControlEventTouchUpInside];

//    [self parsingXML];
    
    // Do any additional setup after loading the view.
}
//
//- (void)parsingXML{
//    nsbun
//}



- (void)presentToSecond{
    [self.adPlayer removeFromSuperview];
    self.adPlayer = nil;
//    NSLog(@"发送销毁");
//    [self.navigationController pushViewController:[YhsADFullScreenViewController new] animated:YES];
//    [self presentViewController:[YhsADFullScreenViewController new] animated:YES completion:nil];
}

#pragma mark -- 需要设置全局支持旋转方向，然后重写下面三个方法可以让当前页面支持多个方向
// 是否支持自动转屏
- (BOOL)shouldAutorotate {
    return NO;
}
// 支持哪些屏幕方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}
// 默认的屏幕方向（当前ViewController必须是通过模态出来的UIViewController（模态带导航的无效）方式展现出来的，才会调用这个方法）
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeLeft;
}



@end
