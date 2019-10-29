//
//  YhsADFullScreenViewController.m
//  CustomPlayer
//
//  Created by 熊俊 on 2019/10/21.
//  Copyright © 2019 熊俊. All rights reserved.
//

#import "YhsADFullScreenViewController.h"
#import "YhsADPlayer.h"

@interface YhsADFullScreenViewController ()

@property (nonatomic,strong) YhsADPlayer *adPlayer;

@end

@implementation YhsADFullScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.adPlayer = [YhsADPlayer new];
    self.adPlayer.frame = CGRectMake(0, 88, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width*9/16);
    self.adPlayer.playUrl = @"http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4";
    //    self.adPlayer.center = self.view.center;
    self.adPlayer.viewController = self;
    //    self.adPlayer.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_adPlayer];
    
    // Do any additional setup after loading the view.
}

//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
//{
//    return UIInterfaceOrientationLandscapeLeft;
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc
{
    NSLog(@"被销毁");
}

@end
