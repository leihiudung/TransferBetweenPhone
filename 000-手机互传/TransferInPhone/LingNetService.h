//
//  LingNetService.h
//  000-手机互传
//
//  Created by Tom-Li on 2019/8/21.
//  Copyright © 2019 Dong&Ling. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class GCDAsyncSocket;

@protocol LingServiceDelegate <NSObject>

- (void)lingFoundService:(NSArray<NSNetService *> *)netServices;

@end

@interface LingNetService : NSObject

@property (nonatomic, assign) id<LingServiceDelegate> lingDelegate;

- (instancetype)initWithNetServiceName:(NSString *)serviceName andLingDelegate:(id<LingServiceDelegate>)lingDelegate;
@end

NS_ASSUME_NONNULL_END
