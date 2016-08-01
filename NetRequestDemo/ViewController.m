//
//  ViewController.m
//  NetRequestDemo
//
//  Created by ileo on 16/3/28.
//  Copyright © 2016年 ileo. All rights reserved.
//

#import "ViewController.h"
#import "NetTest.h"
#import "NetStatus.h"

@interface ViewController ()



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(50, 50, 50, 50)];
    [self.view addSubview:button];
    [button addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor yellowColor];
    button.titleLabel.text = @"点我";
    
    UIButton *haha = [[UIButton alloc] initWithFrame:CGRectMake(150, 50, 50, 50)];
    [self.view addSubview:haha];
    [haha addTarget:self action:@selector(haha) forControlEvents:UIControlEventTouchUpInside];
    haha.backgroundColor = [UIColor blueColor];
    haha.titleLabel.text = @"点我";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(haha) name:NetStatusDidChanged object:nil];
    
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)click{
    
    dispatch_semaphore_t semap = dispatch_semaphore_create(0);
    
    dispatch_async(dispatch_queue_create("aa", NULL), ^{
        
        for (int i = 0; i < 10; i++) {
            
            NSLog(@"aa");
            
            dispatch_async(dispatch_get_main_queue(), ^{
            
                [[[[NetTest test] requestNeedShowLoading] requestNoJson] requestSuccess:^(id JSON) {
                    
                    dispatch_semaphore_signal(semap);
                    NSLog(@"success - %@",JSON);
                } failure:^(id JSON) {
                    dispatch_semaphore_signal(semap);
                    NSLog(@"fail -%@",JSON);
                }];
                
            });
            
            dispatch_semaphore_wait(semap, DISPATCH_TIME_FOREVER);

        }
        
    });

}

-(void)haha{
    NSLog(@"haha---%@  --wifi:%@  ---wwan:%@",[NetStatus sharedInstance].currentNetworkStatusDescribe,[NetStatus sharedInstance].wifiIPAddress,[NetStatus sharedInstance].WWANIPAddress);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
