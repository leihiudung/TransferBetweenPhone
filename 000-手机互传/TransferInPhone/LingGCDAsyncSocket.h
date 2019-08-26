//
//  LingGCDAsyncSocket.h
//  000-手机互传
//
//  Created by Tom-Li on 2019/8/22.
//  Copyright © 2019 Dong&Ling. All rights reserved.
//

#import <CocoaAsyncSocket/GCDAsyncSocket.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@protocol LingGCDAsyncSocketDelegate <NSObject>
@optional
- (void)lingAcceptNewSocket:(GCDAsyncSocket *)newsocket andServerSocket:(GCDAsyncSocket *)serverSocket andClientNetService:(nullable NSNetService *)clientSerivce;

- (void)lingReadData:(UIImage *)image;
@end

typedef void(^LingReadImageSendByClient)(UIImage *);

@interface LingGCDAsyncSocket : GCDAsyncSocket

@property (nonatomic, assign) id<LingGCDAsyncSocketDelegate> asyncSocketDelegate;
//- (instancetype)initWithDelegate:(id)asyncSocketDelegate;

- (void)releaseAsyncSocket;
- (GCDAsyncSocket *)obtainSocket;
@end

NS_ASSUME_NONNULL_END
