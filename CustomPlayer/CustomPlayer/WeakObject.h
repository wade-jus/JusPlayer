//
//  WeakObject.h
//  CustomPlayer
//
//  Created by 熊俊 on 2019/10/23.
//  Copyright © 2019 熊俊. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WeakObject : NSObject

+ (instancetype)proxyWeakObject:(id)obj;

@end

NS_ASSUME_NONNULL_END
