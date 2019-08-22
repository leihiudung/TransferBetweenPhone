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

#import <CocoaAsyncSocket/GCDAsyncSocket.h>

#define CellId @"CellId"


@interface TransferViewController () <UITableViewDataSource,UITableViewDelegate, LingServiceDelegate>
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray<NSNetService *> *netServices;

@property (nonatomic, strong) LingNetService *lingNetService;
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
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSString *serviceName = [[UIDevice currentDevice] name];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        self.lingNetService = [[LingNetService alloc]initWithNetServiceName:serviceName andLingDelegate:self];
    });
    
//    self.lingNetService.lingDelegate = self;
    
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
    AlbumViewController *controller = [[AlbumViewController alloc]init];
    [self presentViewController:controller animated:YES completion:nil];
    
}

- (void)lingFoundService:(NSArray<NSNetService *> *)netServices {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.netServices = netServices.copy;
        [self.tableView reloadData];
    });
    
}

@end
