//
//  LingNetService.m
//  000-手机互传
//
//  Created by Tom-Li on 2019/8/21.
//  Copyright © 2019 Dong&Ling. All rights reserved.
//

#import "LingNetService.h"

#define NetServiceType @"_LingDong._tcp"
#define NetServiceDomain @"local."

@interface LingNetService() <NSNetServiceDelegate, NSNetServiceBrowserDelegate> {
    NSString *_deviceName;
}
@property (nonatomic, strong) NSNetService *netService;

@property (nonatomic, strong) NSNetServiceBrowser *netServiceBrowser;

@property (nonatomic, strong) NSMutableArray<NSNetService *> *netServiceArray;
@end

@implementation LingNetService

- (instancetype)initWithNetServiceName:(NSString *)serviceName andLingDelegate:(id<LingServiceDelegate>)lingDelegate
{
    self = [super init];
    if (self) {
        _deviceName = serviceName;
        self.lingDelegate = lingDelegate;
        self.netServiceArray = [NSMutableArray array];
        [self initLingNetService];
    }
    return self;
}

// 发送广播
- (void)initLingNetService {
    NSNetService *service = [[NSNetService alloc]initWithDomain:NetServiceDomain type:NetServiceType name:_deviceName port:1202];
    [service scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    service.delegate = self;
    NSData *data = [NSNetService dataFromTXTRecordDictionary:@{@"node": @"http://www.baidu.com"}];
    [service setTXTRecordData:data];
    self.netService = service;
    // 发布服务
    [service publish];
    
    // ---- 查找服务 ----
    self.netServiceBrowser = [[NSNetServiceBrowser alloc]init];
    self.netServiceBrowser.delegate = self;
    NSRunLoop *currentLoop = [NSRunLoop currentRunLoop];
    // NSNetServiceBrowser是使用run loop实现不断循环搜索的，类似于NSTimer，主线程中默认开启了runloop，而子线程中默认没有创建runloop，所以需要自己创建并开启一个RunLoop，然后把NSNetServiceBrowser使用scheduleInRunLoop:forMode: 添加到runloop里，这样Bonjour才能开始工作
    [self.netServiceBrowser scheduleInRunLoop:currentLoop forMode:NSRunLoopCommonModes];
    // 查找的服务类型
    [self.netServiceBrowser searchForServicesOfType:NetServiceType inDomain:NetServiceDomain];
    [currentLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:300]];
    
    
}

// netservice
- (void)netServiceWillPublish:(NSNetService *)sender {
    NSLog(@"net service will publish");
}

- (void)netServiceDidPublish:(NSNetService *)sender {
    NSLog(@"the service had published");
}

- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary<NSString *,NSNumber *> *)errorDict {
    NSLog(@"the publish execution make error");
}

/*
 * 开始解析
 */
- (void)netServiceWillResolve:(NSNetService *)sender {
    NSLog(@"resolve addr will done");
}

/*
 * 解析服务失败，解析出错
 */
- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary<NSString *, NSNumber *> *)errorDict {
    NSLog(@"------------netService didNotResolve  =%@",errorDict);
}

/*
 * 停止服务
 */
- (void)netServiceDidStop:(NSNetService *)sender {
    NSLog(@"--------------netServiceDidStop");
}

/*
 * 服务数据更新
 */
- (void)netService:(NSNetService *)sender didUpdateTXTRecordData:(NSData *)data {
    NSLog(@"--------------netService didUpdateTXTRecordData");
}

/*
 * 连接成功输出流和输入流
 */
- (void)netService:(NSNetService *)sender didAcceptConnectionWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream {
    NSLog(@"--------------netService didAcceptConnectionWithInputStream");
    
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender {
    NSLog(@"---------------netService didResolveAddress");
    
}


// NetServiceBrowser
/*
 * 即将查找服务
 */
- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)browser {
    NSLog(@"-----------------netServiceBrowserWillSearch");
}

/*
 * 停止查找服务
 */
- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)browser {
    NSLog(@"-----------------netServiceBrowserDidStopSearch");
}

/*
 * 查找服务失败
 */
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didNotSearch:(NSDictionary<NSString *, NSNumber *> *)errorDict {
    NSLog(@"----------------netServiceBrowser didNotSearch");
}

/*
 * 发现域名服务
 */
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindDomain:(NSString *)domainString moreComing:(BOOL)moreComing {
    NSLog(@"---------------netServiceBrowser didFindDomain");
}

/*
 * 发现客户端服务
 */
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing {
    NSLog(@"netServiceBrowser didFindService---------=%@  =%@  =%@",service.name,service.addresses,service.hostName);
    [self.netServiceArray addObject:service];
    [service resolveWithTimeout:5];
    if ([self.lingDelegate respondsToSelector:@selector(lingFoundService:)]) {
        [self.lingDelegate lingFoundService:self.netServiceArray.copy];
    }
    
}

/*
 * 域名服务移除
 */
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didRemoveDomain:(NSString *)domainString moreComing:(BOOL)moreComing {
    NSLog(@"---------------netServiceBrowser didRemoveDomain");
}

/* 被链接时作为服务端,与客户端交互
 * 客户端服务移除
 */
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing {
    NSLog(@"---------------netServiceBrowser didRemoveService");
    [self.netServiceArray removeObject:service];
    if ([self.lingDelegate respondsToSelector:@selector(lingFoundService:)]) {
        [self.lingDelegate lingFoundService:self.netServiceArray.copy];
    }
}

@end
