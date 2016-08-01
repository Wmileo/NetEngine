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
    return [__SELF requestFullPath:@"http://101.201.102.76:8080/ubt/pv?accessTime=1470037427596&app=cz&data%5Bios%5D%5Bversion%5D=4.2.2&leaveTime=1470037433717&prePVID=&pvid=ios-4.2.2-%E9%A6%96%E9%A1%B5&ubt_client_type=ios&ubt_client_version=1.0.0&uid=245563" withFullParams:nil type:REQUEST_POST];
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
