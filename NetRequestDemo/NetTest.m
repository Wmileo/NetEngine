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

-(id<NetRequestConfig>)requestDefaultConfig{
    return self;
}

+(NetTest *)test{
    return [__SELF request:@"/login/hello" withParams:@{} type:REQUEST_POST];
}

-(NSString *)requestMainURL{
    return @"http://s.qianbaocard.com/";
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

-(NSDictionary *)requestLinkErrorMessageWithError:(NSError *)error response:(NSURLResponse *)response{
    return @{@"errMsg":@"error-link"};
}

-(NSDictionary *)requestFinalParamsWithSplicedParams:(NSDictionary *)spliced{
    return @{@"data":@"yitbDd0xAj76KPdmQhDPTQ=="};
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

-(NSDictionary *)finalResponseObjectWithResponse:(NSDictionary *)response{
    return @{};
}

-(void)configAFHTTPSessionManager:(AFHTTPSessionManager *)httpManager{
    httpManager.requestSerializer = [AFJSONRequestSerializer serializer];
    [httpManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
}

@end
