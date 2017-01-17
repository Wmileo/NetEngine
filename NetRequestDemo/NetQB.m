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
    return @"http://10.10.13.19:8080";
//    return @"http://10.10.13.1:8080";
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
    
//    [[__SELF configRequest:[QBRequest postPath:@"api-gateway/api/basic/get_server_time" params:@{@"a":@[@"  1",@"2",@"8",@"3"],@"b":@{@"ab":@"b",@"aa":@"c"}}]] requestCallBack:^(NetResponseModel *model) {
//        if (callback) {
//            callback(model);
//        }
//    }];
    
//    [[__SELF configRequest:[QBRequest postPath:@"api-gateway/api/basic/get_server_time" params:@{@"a":@"c",@"b":@"a"}]] requestCallBack:^(NetResponseModel *model) {
//        if (callback) {
//            callback(model);
//        }
//    }];
    
    [[__SELF configRequest:[QBRequest requestWithPath:@"api-gateway/api/basic/get_server_time" params:nil]] requestCallBack:^(NetResponseModel *model) {
        if (callback) {
            callback(model);
        }
    }];
    
}

static NSString *sign_key = @"ilwHaGnQtdFxU1cK";
static NSString *encrypt_iv = @"L+\\~f4,Ir)b$=pkf";
static NSString *encrypt_key = @"Q1anBa0*ShengHu0";

-(void)handleRequestInfoWithNetEngine:(NetEngine *)engine{
    
    [engine.requestModel addParams:@{@"_platform" : @"app",
                                     @"_os" : @"ios",
                                     @"_sysVersion" : @"test",
                                     @"_model" : @"test",
                                     @"_appVersion" : @"test",
                                     @"_v" : @"test",
                                     @"_openUDID" : @"test",
                                     @"_cUDID" : @"test",
                                     @"_appChannel" : @"test",
                                     @"_caller" : @"test",
                                     @"_ac_token" : @"test",
                                     @"c" : @[@"a",@"b"],
                                     }];
    
    NSString *query = AFQueryStringFromParameters(engine.requestModel.params);
    NSString *path = engine.requestModel.path;
    path = [NSString stringWithFormat:@"%@%@%@",path,[path containsString:@"?"] ? @"&" : @"?", query];
    query = [path componentsSeparatedByString:@"?"][1];
    
    NSString *sign = [[NSString stringWithFormat:@"%@%@",[[NSString stringWithFormat:@"%@&",query] encodeWithMD5],sign_key] encodeWithMD5];
    
    if (engine.requestModel.type == POST) {
        NSDictionary *postDic = ((QBRequest *)engine.requestModel).postParams;
        engine.requestModel.params = postDic;
        sign = [[NSString stringWithFormat:@"%@%@",sign,[[NSString stringWithFormat:@"%@%@",[AFQueryStringFromParameters(postDic) encodeWithMD5],sign_key] encodeWithMD5]] encodeWithMD5];
    }
    engine.requestModel.params = nil;
    engine.requestModel.path = [NSString stringWithFormat:@"%@&_sign=%@",path,sign];
    
}

-(void)handleResponseInfoWithNetEngine:(NetEngine *)engine{
    NetResponseModel *model = engine.responseModel;
    model.message = @"网络连接失败了，稍后再试吧";
    if ([model.allHeaderFields[@"response_encrypt"] boolValue]){
        
        NSString *str = [[NSString alloc] initWithData:model.responseObject encoding:NSUTF8StringEncoding];
        NSString *new = [str decryptAESWithKey:encrypt_key iv:encrypt_iv];
        NSLog(@"%@",new);
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:new options:NSJSONReadingMutableContainers error:nil];
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
