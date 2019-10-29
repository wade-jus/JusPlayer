//
//  YhsADPlayer.h
//  CustomPlayer
//
//  Created by 熊俊 on 2019/10/21.
//  Copyright © 2019 熊俊. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YhsADPlayer : UIView

@property (nonatomic,copy) NSString *playUrl;

@property (nonatomic,weak) UIViewController *viewController;

@end

NS_ASSUME_NONNULL_END
