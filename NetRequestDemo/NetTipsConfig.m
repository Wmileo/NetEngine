//
//  NetTipsConfig.m
//  NetRequestDemo
//
//  Created by ileo on 16/4/6.
//  Copyright © 2016年 ileo. All rights reserved.
//

#import "NetTipsConfig.h"

@implementation NetTipsConfig

-(void)showLoading{
    NSLog(@"showLoading");
}

-(void)disappearLoading{
    NSLog(@"disappearLoading");
}

-(void)showTips:(NSString *)tips{
    NSLog(@"showTips:%@",tips);
}

@end
