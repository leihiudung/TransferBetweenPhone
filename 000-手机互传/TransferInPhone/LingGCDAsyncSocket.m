//
//  LingGCDAsyncSocket.m
//  000-手机互传
//
//  Created by Tom-Li on 2019/8/22.
//  Copyright © 2019 Dong&Ling. All rights reserved.
//

#import "LingGCDAsyncSocket.h"

static const NSInteger AppPort = 1202;

@interface LingGCDAsyncSocket() <GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket *serverSocket;



@end

@implementation LingGCDAsyncSocket

- (instancetype)init
{
    self = [super init];
    if (self) {
//        static dispatch_once_t onceToken;

//        dispatch_once(&onceToken, ^{
            self.serverSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
//            self.asyncSocketDelegate = asyncSocketDelegate;
            NSError *serverError;
            [self.serverSocket acceptOnPort:AppPort error:&serverError];
//        });
        
        
    }
    return self;
}



- (void)socketDidCloseReadStream:(GCDAsyncSocket *)sock {
    NSLog(@"socket didCloseReadStream");
}


- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    // 心跳
    [self.serverSocket readDataWithTimeout:-1 tag:0];
    NSLog(@"socket didConnectToHost");
}

// 连接上新的客户端socket
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    NSLog(@"又在调用 didAcceptnewSocket了");
    [newSocket readDataWithTimeout:-1 tag:0];

    if ([self.asyncSocketDelegate respondsToSelector:@selector(lingAcceptNewSocket:andServerSocket:andClientNetService:)]) {
        [self.asyncSocketDelegate lingAcceptNewSocket:newSocket andServerSocket:self.serverSocket andClientNetService:nil];
    }

}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    UIImage *image = [UIImage imageWithData:data];
    if (image != nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AsyncSocketDidReadData" object:nil userInfo:@{@"Image": image}];
    }
   [self.serverSocket readDataWithTimeout:-1 tag:0];
}

- (void)dealloc
{
    NSLog(@"dealloc");
}

- (void)releaseAsyncSocket {
    self.asyncSocketDelegate = nil;
    [self.serverSocket disconnect];
//    [self.serverSocket release];
    self.serverSocket = nil;
}

- (GCDAsyncSocket *)obtainSocket {
    return self.serverSocket;
}

@end
