//
//  ViewController.m
//  000-手机互传
//
//  Created by Tom-Li on 2019/8/21.
//  Copyright © 2019 Dong&Ling. All rights reserved.
//

#import "ViewController.h"
#import "TransferViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton *jumpBtn = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 160, 60)];
    [jumpBtn setTitle:@"Jump" forState:UIControlStateNormal];
    [jumpBtn setBackgroundColor:[UIColor blueColor]];
    [self.view addSubview:jumpBtn];
    
    [jumpBtn addTarget:self action:@selector(jumpAction:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)jumpAction:(id)sender {
    TransferViewController *controller = [[TransferViewController alloc]init];
    [self presentViewController:controller animated:YES completion:nil];
    
}
@end
