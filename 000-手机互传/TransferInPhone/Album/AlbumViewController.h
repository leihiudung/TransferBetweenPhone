//
//  AlbumViewController.h
//  000-手机互传
//
//  Created by Tom-Li on 2019/8/21.
//  Copyright © 2019 Dong&Ling. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LingGCDAsyncSocket;
@class GCDAsyncSocket;
NS_ASSUME_NONNULL_BEGIN

@interface AlbumViewController : UIViewController

- (instancetype)initAsServer:(GCDAsyncSocket *)clientSocket andServerSocket:(GCDAsyncSocket *)serverSocket andClientNetService:(NSNetService *)service andLingGCDAsyncSocket:(LingGCDAsyncSocket *)asyncSocket;
- (instancetype)initAsClient:(NSNetService *)netService;
@end

NS_ASSUME_NONNULL_END
