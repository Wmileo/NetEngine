//
//  NetTest.m
//  NetRequestDemo
//
//  Created by ileo on 16/4/1.
//  Copyright © 2016年 ileo. All rights reserved.
//

#import "NetTest.h"

@interface NetTest () <NetRequestConfig,NetEngineDelegate>

@end

@implementation NetTest

-(void)dealloc{


}

-(instancetype)init{
    self = [super init];
    if (self) {
        [self requestWithConfig:self];
    }
    return self;
}

+(NetTest *)test{
    return [__SELF request:@"/test/res" withParams:@{@"c":@"d"} type:REQUEST_POST];
}

-(NSString *)requestMainURL{
    return @"http://115.159.49.124:8080/CarcareService";
}

-(NSDictionary *)requestCommonParams{
    return nil;
}

-(BOOL)requestIsSuccessWithResponse:(id)responseObject{
    return [responseObject[@"errFlag"] boolValue];
}

-(NSString *)requestFailureMessageWithResponse:(id)responseObject{
    return responseObject[@"errMsg"];
}

-(void)requestHandleWithErrorCodeWithResponse:(id)responseObject{
    NSLog(@"%@",responseObject[@"errCode"]);
}

-(NSDictionary *)requestLinkErrorMessage{
    return @{@"errMsg":@"error-link"};
}

-(void)showLoading{
    NSLog(@"showLoading");
}

-(void)disappearLoading{
    NSLog(@"disappearLoading");
}

-(void)showTips:(NSString *)tips{
    NSLog(@"showTips:%@",tips);
}


-(void)requestWillStart{
    NSLog(@"requestWillStart");
}

-(void)requestDidFailure{
    NSLog(@"requestDidFailure");
}

-(void)requestDidSuccess{
    NSLog(@"requestDidSuccess");
}

@end
