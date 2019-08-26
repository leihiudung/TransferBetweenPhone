//
//  TransferViewController.m
//  000-手机互传
//
//  Created by Tom-Li on 2019/8/21.
//  Copyright © 2019 Dong&Ling. All rights reserved.
//

#import "TransferViewController.h"
#import "LingNetService.h"
#import "AlbumViewController.h"
#import "LingGCDAsyncSocket.h"

#import <CocoaAsyncSocket/GCDAsyncSocket.h>
#import <Photos/Photos.h>
#define CellId @"CellId"


@interface TransferViewController () <UITableViewDataSource,UITableViewDelegate, LingServiceDelegate, LingGCDAsyncSocketDelegate>
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray<NSNetService *> *netServices;

@property (nonatomic, strong) LingNetService *lingNetService;
@property (nonatomic, strong) LingGCDAsyncSocket *lingGCDAsyncSocket;
@end

@implementation TransferViewController

- (void)loadView {
    [super loadView];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellId];
    [self.view addSubview:self.tableView];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.lingGCDAsyncSocket = [[LingGCDAsyncSocket alloc]init];
    self.lingGCDAsyncSocket.asyncSocketDelegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSString *serviceName = [[UIDevice currentDevice] name];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        self.lingNetService = [[LingNetService alloc]initWithNetServiceName:serviceName andLingDelegate:self];
    });
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(asyncSocketDidReadData) name:@"AsyncSocketDidReadData" object:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.netServices == nil ? 0 : self.netServices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellId];
    cell.textLabel.text = self.netServices[indexPath.row].name;
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AlbumViewController *controller = [[AlbumViewController alloc] initAsClient:self.netServices[indexPath.row]];
    UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:controller];

    [self presentViewController:navigationController animated:YES completion:nil];
    
}

- (void)lingFoundService:(NSArray<NSNetService *> *)netServices {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (NSNetService *tempService in netServices) {
            NSLog(@"**lingFoundService: %@", tempService.hostName);
        }
        
        self.netServices = netServices.copy;
        [self.tableView reloadData];
    });
    
}

- (void)lingAcceptNewSocket:(GCDAsyncSocket *)newsocket andServerSocket:(GCDAsyncSocket *)serverSocket andClientNetService:(NSNetService *)clientSerivce {
    AlbumViewController *controller = [[AlbumViewController alloc] initAsServer:newsocket andServerSocket:self.lingGCDAsyncSocket.obtainSocket andClientNetService:clientSerivce andLingGCDAsyncSocket:self.lingGCDAsyncSocket];
    UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:controller];
    
    [self presentViewController:navigationController animated:YES completion:nil];

}

//- (void)asyncSocketDidReadData:(NSNotification *)notification {
//    NSDictionary *dict = notification.userInfo;
//    UIImage *image = dict[@"Image"];
//
//    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
//        [PHAssetChangeRequest creationRequestForAssetFromImage:image];
//    } completionHandler:^(BOOL success, NSError * _Nullable error) {
//        if (error) {
//            NSLog(@"Saving was make a misstake");
//        }
//    }];
//}

@end
