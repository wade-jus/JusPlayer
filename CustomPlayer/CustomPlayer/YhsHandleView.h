//
//  YhsHandleView.h
//  CustomPlayer
//
//  Created by 熊俊 on 2019/10/22.
//  Copyright © 2019 熊俊. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HandleDelegate <NSObject>

@optional
- (void)fullScreen;

- (void)playClick:(UIButton *)sender;

@end

@interface YhsHandleView : UIView

@property (nonatomic,weak) id <HandleDelegate> delegate;

@property (nonatomic,assign) BOOL isDisappear;

@property (nonatomic,copy) NSString *totalTimeString;

@property (nonatomic,copy) NSString *currentTimeString;

@property (nonatomic,assign) CGFloat progress;

@property (nonatomic,assign) CGFloat loadProgress;

@property (nonatomic,copy) void(^endPlayBlock)(void);

@property (nonatomic,copy) void(^touchProcess)(NSInteger state,CGFloat newValue);

@end

NS_ASSUME_NONNULL_END
