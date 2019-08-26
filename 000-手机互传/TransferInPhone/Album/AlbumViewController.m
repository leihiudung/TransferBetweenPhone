//
//  AlbumViewController.m
//  000-手机互传
//
//  Created by Tom-Li on 2019/8/21.
//  Copyright © 2019 Dong&Ling. All rights reserved.
//

#import "AlbumViewController.h"
#import "AlbumService.h"

#import "AlbumCollectionViewCell.h"

#import "LingGCDAsyncSocket.h"
#import <Photos/Photos.h>
#import <CocoaAsyncSocket/GCDAsyncSocket.h>

static const NSInteger AppProt = 1202;

@interface AlbumViewController () <UICollectionViewDataSource, UICollectionViewDelegate, GCDAsyncSocketDelegate, NSNetServiceDelegate, LingGCDAsyncSocketDelegate> {
    CGSize thumbnailSize;
    CGRect previousPreheatRect;
    
    BOOL _isChosenAll;
}
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) PHFetchResult<PHAsset *> *fetchResult;

@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic, strong) PHImageRequestOptions *requestOption;

@property (nonatomic, strong) NSTimer *connectTimer;


// 本机作为客户端
@property (nonatomic, strong) GCDAsyncSocket *clientSocket;
@property (nonatomic, strong) GCDAsyncSocket *serverSocket;

@property (nonatomic, strong) NSMutableArray<UIImage *> *selectedImage;

@property (nonatomic, strong) LingGCDAsyncSocket *lingGCDAsyncSocket;
@end

@implementation AlbumViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.selectedImage = [NSMutableArray array];
    }
    return self;
}

- (instancetype)initAsServer:(GCDAsyncSocket *)clientSocket andServerSocket:(GCDAsyncSocket *)serverSocket andClientNetService:(NSNetService *)service andLingGCDAsyncSocket:(nonnull LingGCDAsyncSocket *)asyncSocket
{
    self = [super init];
    if (self) {
        self.clientSocket = clientSocket;
        self.clientSocket.delegate = self;
//        self.serverSocket = serverSocket;
//        self.serverSocket.delegate = self;
//        self.lingGCDAsyncSocket = asyncSocket;
//        self.lingGCDAsyncSocket = [[LingGCDAsyncSocket alloc]init];
//        self.lingGCDAsyncSocket.asyncSocketDelegate = self;

    }
    return self;
}

- (instancetype)initAsClient:(NSNetService *)netService
{
    self = [super init];
    if (self) {
        [self initGCDSocket:netService];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    self.navigationItem.title = @"File Transfer";
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.lingGCDAsyncSocket = [[LingGCDAsyncSocket alloc]initWithDelegate:self];
    
    self.selectedImage = [NSMutableArray array];
    _imageManager = [[PHCachingImageManager alloc] init];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    [flowLayout setItemSize:CGSizeMake(UIScreen.mainScreen.bounds.size.width / 3 - 20, UIScreen.mainScreen.bounds.size.width / 3 - 20)];
    
    [flowLayout setMinimumLineSpacing:5];
    [flowLayout setMinimumInteritemSpacing:5];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    self.collectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    [self.collectionView registerClass:[AlbumCollectionViewCell class] forCellWithReuseIdentifier:@"CellId"];
    [self.view addSubview:self.collectionView];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"Chosen" style:UIBarButtonItemStyleDone target:self action:@selector(chosenAction:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithTitle:@"Send" style:UIBarButtonItemStyleDone target:self action:@selector(sendAction:)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(asyncSocketDidReadData:) name:@"AsyncSocketDidReadData" object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//     self.fetchResult = [[AlbumService share] getAllPhotos];
    PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc] init];
    // 按创建时间升序
    allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    self.fetchResult = [PHAsset fetchAssetsWithOptions:allPhotosOptions];
    
    [self.collectionView reloadData];
}

/**
 初始化GCDAsyncSocket 客户端
 */
- (void)initGCDSocket:(NSNetService *)netService {
    NSString *deviceName = netService.hostName;
//    deviceName = @"iPhone";
    // 开始加载发现的手机
    self.clientSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSError *error;
    [self.clientSocket connectToHost:[NSString stringWithFormat:@"%@", deviceName] onPort:AppProt error:&error];
    if (error != nil) {
        NSLog(@"done %@", error);
    }
    [self addTimer];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.fetchResult.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AlbumCollectionViewCell *cell = (AlbumCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CellId" forIndexPath:indexPath];
    
    PHAsset *asset = self.fetchResult[indexPath.item];
//    cell.isChosenAll = _isChosenAll;
    cell.selected = _isChosenAll;
    cell.representedAssetIdentifier = asset.localIdentifier;
    [self.imageManager requestImageForAsset:asset targetSize:thumbnailSize contentMode:PHImageContentModeAspectFill options:_requestOption resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if ([cell.representedAssetIdentifier isEqualToString:asset.localIdentifier]) {
            cell.thumbnailImage = result;
        }
    }];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    AlbumCollectionViewCell *tempCell = (AlbumCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [tempCell setIsChosen:!tempCell.isChosen];
    tempCell.isChosen ? [self.selectedImage addObject:tempCell.thumbnailImage] : [self.selectedImage removeObject:tempCell.thumbnailImage];
    NSLog(@"done");
}

/**
 重置缓存资源(图片)
 */
- (void)resetCachedAssets
{
    [_imageManager stopCachingImagesForAllAssets];
    previousPreheatRect = CGRectZero;
}


/**
 更新缓存资源(图片)
 */
- (void)updateCachedAssets
{
    // isViewLoaded: A Boolean value indicating whether the view is currently loaded into memory.
    if (!self.isViewLoaded || self.view.window == nil) {
        return;
    }
    
    // 预热区域 preheatRect 是 可见区域 visibleRect 的两倍高
    CGRect visibleRect = CGRectMake(0.f, self.collectionView.contentOffset.y, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    // 相当于可视窗体向下移动,对于preheatRect代表的长型框来说,则窗体的起点距离preheatRect的顶点越来越远(值由负数变为正数),离原点(x=0, y=0)越来越近
    CGRect preheatRect = CGRectInset(visibleRect, 0, -0.5*visibleRect.size.height);
    //    CGRect v2 = CGRectMake(0, -64, 320, 632);
    //    CGRect preheatRect3 =  CGRectInset(v2, 0, -0.5*v2.size.height);
    // 相当于在这里调用
    // 只有当可见区域与最后一个预热区域显著不同时才更新
    CGFloat delta = fabs(CGRectGetMidY(preheatRect) - CGRectGetMidY(previousPreheatRect));
    if (delta > self.view.bounds.size.height / 3.f) {
        // 计算开始缓存和停止缓存的区域
        [self computeDifferenceBetweenRect:previousPreheatRect andRect:preheatRect removedHandler:^(CGRect removedRect) {
            [self imageManagerStopCachingImagesWithRect:removedRect];
        } addedHandler:^(CGRect addedRect) {
            [self imageManagerStartCachingImagesWithRect:addedRect];
        }];
        previousPreheatRect = preheatRect;
    }
}

/**
 计算滚动的Rectangle的范围

 @param oldRect
 @param newRect
 @param removedHandler
 @param addedHandler
 */
- (void)computeDifferenceBetweenRect:(CGRect)oldRect andRect:(CGRect)newRect removedHandler:(void (^)(CGRect removedRect))removedHandler addedHandler:(void (^)(CGRect addedRect))addedHandler
{
    if (CGRectIntersectsRect(newRect, oldRect)) {
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        //添加 向下滑动时 newRect 除去与 oldRect 相交部分的区域（即：屏幕外底部的预热区域）
        if (newMaxY > oldMaxY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }
        //添加 向上滑动时 newRect 除去与 oldRect 相交部分的区域（即：屏幕外底部的预热区域）
        if (oldMinY > newMinY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }
        //移除 向上滑动时 oldRect 除去与 newRect 相交部分的区域（即：屏幕外底部的预热区域）
        if (newMaxY < oldMaxY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }
        //移除 向下滑动时 oldRect 除去与 newRect 相交部分的区域（即：屏幕外顶部的预热区域）
        if (oldMinY < newMinY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
    }
    else {
        //当 oldRect 与 newRect 没有相交区域时
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}

- (void)imageManagerStartCachingImagesWithRect:(CGRect)rect
{
    NSMutableArray<PHAsset *> *addAssets = [self indexPathsForElementsWithRect:rect];
    [_imageManager startCachingImagesForAssets:addAssets targetSize:thumbnailSize contentMode:PHImageContentModeAspectFill options:_requestOption];
}

- (void)imageManagerStopCachingImagesWithRect:(CGRect)rect
{
    NSMutableArray<PHAsset *> *removeAssets = [self indexPathsForElementsWithRect:rect];
    [_imageManager stopCachingImagesForAssets:removeAssets targetSize:thumbnailSize contentMode:PHImageContentModeAspectFill options:_requestOption];
}

- (NSMutableArray<PHAsset *> *)indexPathsForElementsWithRect:(CGRect)rect
{
    UICollectionViewLayout *layout = self.collectionView.collectionViewLayout;
    NSArray<__kindof UICollectionViewLayoutAttributes *> *layoutAttributes = [layout layoutAttributesForElementsInRect:rect];
    NSMutableArray<PHAsset *> *assets = [NSMutableArray array];
    for (__kindof UICollectionViewLayoutAttributes *layoutAttr in layoutAttributes) {
        NSIndexPath *indexPath = layoutAttr.indexPath;
        PHAsset *asset = [_fetchResult objectAtIndex:indexPath.item];
        [assets addObject:asset];
    }
    return assets;
}

#pragma mark - UIScrollViewDelegate -
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateCachedAssets];
}

- (void)chosenAction:(UIBarButtonItem *)sender {
    if ([sender.title isEqualToString:@"Chosen"] ) {
        sender.title = @"Cancel";
        _isChosenAll = YES;
    } else {
        sender.title = @"Chosen";
        _isChosenAll = NO;
    }
    [self.collectionView reloadData];
    
}

- (void)sendAction:(UIBarButtonItem *)sender {
    for (UIImage *tempImage in self.selectedImage) {
//        UIImagePNGRepresentation(tempImage);
        NSData *imageData = UIImagePNGRepresentation(tempImage);
        [self.clientSocket writeData:UIImagePNGRepresentation(tempImage) withTimeout:-1 tag:0];
    }
    
    
}

// ---- 心跳定时器 -----
// 添加定时器
- (void)addTimer
{
    // 长连接定时器
    self.connectTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(longConnectToSocket) userInfo:nil repeats:YES];
    // 把定时器添加到当前运行循环,并且调为通用模式
    [[NSRunLoop currentRunLoop] addTimer:self.connectTimer forMode:NSRunLoopCommonModes];
}

// 心跳连接
- (void)longConnectToSocket
{
    // 发送固定格式的数据,指令@"longConnect"
    float version = [[UIDevice currentDevice] systemVersion].floatValue;
    NSString *longConnect = [NSString stringWithFormat:@"123%f",version];
    
    NSData  *data = [longConnect dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.clientSocket writeData:data withTimeout:- 1 tag:0];
}

- (void)asyncSocketDidReadData:(NSNotification *)notification {
    NSDictionary *dict = notification.userInfo;
    UIImage *image = dict[@"Image"];
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromImage:image];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Save it was make a misstake");
        }
    }];
}

- (void)lingReadData:(UIImage *)image {
    NSLog(@"done");
}

//- (void)socketDidCloseReadStream:(GCDAsyncSocket *)sock {
//    NSLog(@"socket didCloseReadStream");
//}
//
//
//- (void)socket:(GCDAsyncSocket *)sock didConGCDnectToHost:(NSString *)host port:(uint16_t)port {
//    // 心跳
//    [self.serverSocket readDataWithTimeout:-1 tag:0];
//    NSLog(@"socket didConnectToHost");
//}
//
// 连接上新的客户端socket
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    //    NSLog(@"又在调用 didAcceptnewSocket了 %@, %@", self.services[0].hostName, self.services[0]);
    [newSocket readDataWithTimeout:-1 tag:0];

}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    UIImage *image = [UIImage imageWithData:data];
    if (image != nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AsyncSocketDidReadData" object:nil userInfo:@{@"Image": image}];
    }
    [self.clientSocket readDataWithTimeout:-1 tag:0];

}
@end
