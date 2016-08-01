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
    return [__SELF requestFullPath:@"http://app1.ichezheng.com/CarcareService/Viol5ation/eclicksCityList?userid=58064&session=64510d0f53a4465d9099ced1829eb18f" withFullParams:nil type:REQUEST_HEAD];
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

-(NSDictionary *)requestLinkErrorMessageWithError:(NSError *)error response:(NSURLResponse *)response{
    return @{@"errMsg":@"error-link"};
}

-(NSDictionary *)requestFinalParamsWithSplicedParams:(NSDictionary *)spliced{
    return @{@"hh":@"mm"};
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
