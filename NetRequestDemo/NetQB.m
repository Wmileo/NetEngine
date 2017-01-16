//
//  NetQB.m
//  NetRequestDemo
//
//  Created by leo on 2017/1/16.
//  Copyright © 2017年 ileo. All rights reserved.
//

#import "NetQB.h"
#import "NSString+Encode.h"

@implementation QBRequest

+(NSString *)mainURL{
//    return @"http://10.10.13.19:8080";
    return @"http://10.10.13.1:8080";
}

+(NetRequestModel *)requestWithPath:(NSString *)path params:(NSDictionary *)params{
    NetRequestModel *model = [[NetRequestModel alloc] init];
    model.path = [NSString stringWithFormat:@"%@/%@",[self mainURL],path];
    model.params = params;
    model.type = GET;
    return model;
}

+(QBRequest *)postPath:(NSString *)path params:(NSDictionary *)params{
    QBRequest *model = [[QBRequest alloc] init];
    model.path = [NSString stringWithFormat:@"%@/%@",[self mainURL],path];
    model.postParams = params;
    model.type = POST;
    return model;
}

@end

@implementation NetQB

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self resetConfig:self];
    }
    return self;
}

+(void)testCallBack:(void (^)(NetResponseModel *))callback{
    
    [[__SELF configRequest:[QBRequest postPath:@"api-gateway/api/basic/get_server_time" params:@{@"a":@[@"  1",@"2",@"8",@"3"],@"b":@{@"ab":@"b",@"aa":@"c"}}]] requestCallBack:^(NetResponseModel *model) {
        if (callback) {
            callback(model);
        }
    }];
    
//    [[__SELF configRequest:[QBRequest requestWithPath:@"api-gateway/api/basic/get_server_time" params:nil]] requestCallBack:^(NetResponseModel *model) {
//        if (callback) {
//            callback(model);
//        }
//    }];
    
}

static NSString *sign_key = @"ilwHaGnasdfsfdQtdFxUsdfasdf1cKadfsefwef";
static NSString *encrypt_iv = @"L+\\asdfasdfasdfafasdfaf~f4asdfasdfaf,Ir)b$=pkf";
static NSString *encrypt_key = @"Q1anBafasdfaasdfasdf0*SheafasdfsdfngHu0";

-(void)handleRequestInfoWithNetEngine:(NetEngine *)engine{
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:engine.requestModel.params];
    dic[@"_platform"] = @"app";
    dic[@"_os"] = @"ios";
    dic[@"_sysVersion"] = @"t    est ";
    dic[@"_model"] = @"test";
    dic[@"_appVersion"] = @"test";
    dic[@"_v"] = @"test";
    dic[@"_openUDID"] = @"test";
    dic[@"_cUDID"] = @"test";
    dic[@"_appChannel"] = @"test";
    dic[@"_caller"] = @"test";
    dic[@"_ac_token"] = @"test";
    [engine.requestModel addParams:@{}];
    
    NSString *query = AFQueryStringFromParameters(dic);
    NSString *path = engine.requestModel.path;
    path = [NSString stringWithFormat:@"%@%@%@",path,[path containsString:@"?"] ? @"&" : @"?", query];
    query = [path componentsSeparatedByString:@"?"][1];
    
    NSString *sign = [[NSString stringWithFormat:@"%@%@",[[NSString stringWithFormat:@"%@&",query] encodeWithMD5],sign_key] encodeWithMD5];
    
    if (engine.requestModel.type == POST) {
        NSDictionary *postDic = ((QBRequest *)engine.requestModel).postParams;
        engine.requestModel.params = postDic;
        sign = [[NSString stringWithFormat:@"%@%@",sign,[[NSString stringWithFormat:@"%@%@",[AFQueryStringFromParameters(postDic) encodeWithMD5],sign_key] encodeWithMD5]] encodeWithMD5];
    }
    
    engine.requestModel.path = [NSString stringWithFormat:@"%@&_sign=%@",path,sign];
    
}

-(void)handleResponseInfoWithNetEngine:(NetEngine *)engine{
    NetResponseModel *model = engine.responseModel;
    model.message = @"网络连接失败了，稍后再试吧";
    if ([model.allHeaderFields[@"response_encrypt"] boolValue]){
        
        
    }
    
    if (model.responseObject) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:model.responseObject options:NSJSONReadingMutableContainers error:nil];
        if (json) {
            model.success = [json[@"code"] integerValue] == 0;
            model.data = json[@"data"];
            model.message = json[@"msg"];
            model.code = [NSString stringWithFormat:@"%@",json[@"code"]];
        }
    }
}

-(void)requestWillStartWithNetEngine:(NetEngine *)engine{
    
}

-(void)requestDidSuccessWithNetEngine:(NetEngine *)engine{
    
}

-(void)requestDidFailureWithNetEngine:(NetEngine *)engine{
    
}

@end
