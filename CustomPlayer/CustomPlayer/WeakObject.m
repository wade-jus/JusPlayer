
//
//  WeakObject.m
//  CustomPlayer
//
//  Created by 熊俊 on 2019/10/23.
//  Copyright © 2019 熊俊. All rights reserved.
//

#import "WeakObject.h"

@interface WeakObject()

@property (nullable,nonatomic,weak,readonly) id weakObject;

- (instancetype _Nullable)initWeakObject:(id _Nullable)obj;
+ (instancetype _Nullable)proxyWeakObject:(id _Nullable)obj;

@end

@implementation WeakObject

- (instancetype)initWeakObject:(id)obj{
    _weakObject = obj;
    return self;
}

+ (instancetype)proxyWeakObject:(id)obj{
    return [[WeakObject alloc] initWeakObject:obj];
}

- (id)forwardingTargetForSelector:(SEL)aSelector{
    return _weakObject;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation{
    void *null = NULL;
    [anInvocation setReturnValue:&null];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    return [NSObject instanceMethodSignatureForSelector:@selector(init)];
}

- (BOOL)respondsToSelector:(SEL)aSelector{
    return [_weakObject respondsToSelector:aSelector];
}

- (BOOL)isEqual:(id)object{
    return [_weakObject isEqual:object];
}

+ (NSUInteger)hash{
    return [WeakObject hash];
}

+ (Class)superclass{
    return [WeakObject superclass];
}

+(Class)class{
    return [WeakObject class];
}

- (BOOL)isKindOfClass:(Class)aClass{
    return [_weakObject isKindOfClass:aClass];
}

- (BOOL)isMemberOfClass:(Class)aClass{
    return [_weakObject isMemberOfClass:aClass];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol{
    return [_weakObject conformsToProtocol:aProtocol];
}

- (BOOL)isProxy{
    return YES;
}

-(NSString *)description{
    return [_weakObject description];
}

- (NSString *)debugDescription{
    return [_weakObject debugDescription];
}

@end
