//
//  Net.m
//  NetRequestDemo
//
//  Created by ileo on 16/9/21.
//  Copyright © 2016年 ileo. All rights reserved.
//

#import "Net.h"

@implementation Net

-(id<NetRequest>)configWithTimeout:(NSTimeInterval)timeInterval{
    return [self requestTimeoutInterval:timeInterval];
}

-(id<NetRequest>)configWithNetRequest:(id<NetRequestConfig>)config{
    return [self requestWithConfig:config];
}

-(id<NetRequest>)configWithNetTips:(id<NetTipsConfig>)tipsConfig{
    return [self requestWithTipsConfig:tipsConfig];
}

-(id<NetRequest>)configWithLoadShow:(RequestLoad)load{
    return [self requestWithLoad:load];
}
-(id<NetRequest>)requestWithPath:(NSString *)path params:(NSDictionary *)params type:(REQUEST_TYPE)type{
    return [self request:path withParams:params type:type];
}

-(id<NetRequest>)requestWithFullPath:(NSString *)path fullParams:(NSDictionary *)params type:(REQUEST_TYPE)type{
    return [self requestFullPath:path withFullParams:params type:type];
}

-(void)requestWithSuccess:(void (^)(NSDictionary<NSString *,id> *))success failure:(void (^)(NSDictionary<NSString *,id> *))failure failMistake:(void (^)(NSDictionary<NSString *,id> *))mistake failLink:(void (^)(NSDictionary<NSString *,id> *))link{
    [self requestSuccess:success failure:failure failMistake:mistake failLink:link];
}

-(void)requestWithSuccess:(void (^)(NSDictionary<NSString *,id> *))success failure:(void (^)(NSDictionary<NSString *,id> *))failure{
    [self requestWithSuccess:success failure:failure failMistake:nil failLink:nil];
}

-(void)requestWithSuccess:(void (^)(NSDictionary<NSString *,id> *))success{
    [self requestWithSuccess:success failure:nil failMistake:nil failLink:nil];
}

@end
