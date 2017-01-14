//
//  NetEngine.m
//  NetRequestDemo
//
//  Created by ileo on 16/3/28.
//  Copyright © 2016年 ileo. All rights reserved.
//

#import "NetEngine.h"
#import "AFHTTPSessionManager.h"

@interface NetEngine()

#pragma mark - 请求内容
@property (nonatomic, strong) id<NetConfig> config;
@property (nonatomic, strong) id<NetTipsConfig> tipsConfig;

#pragma mark - 请求提示
@property (nonatomic, assign) BOOL needShowLoading;
@property (nonatomic, assign) BOOL needShowErrorTips;
@property (nonatomic, assign) BOOL needShowSuccessTips;
@property (nonatomic, assign) BOOL isQuiet;

#pragma mark - callback
@property (nonatomic, copy) void (^CallBack)(NetResponseModel *model);

@end

@implementation NetEngine

- (instancetype)init
{
    self = [super init];
    if (self) {
        if (__tipsConfig) {
            [self resetTipsConfig:__tipsConfig];
        }
        if (__Config) {
            [self resetConfig:__Config];
        }
    }
    return self;
}

-(void)releaseConfig{
    self.config = nil;
    self.tipsConfig = nil;
}

#pragma mark - 请求配置
NSTimeInterval __timeInterval;
+(void)setupTimeoutInterval:(NSTimeInterval)timeInterval{
    __timeInterval = timeInterval;
}

-(id)resetTimeout:(NSTimeInterval)timeInterval{
    self.httpManager.requestSerializer.timeoutInterval = timeInterval;
    return self;
}

id<NetConfig> __Config;
+(void)setupDefaultConfig:(id<NetConfig>)config{
    __Config = config;
}

-(id)resetConfig:(id<NetConfig>)config{
    self.config = config;
    return self;
}

#pragma mark - 请求提醒配置
id<NetTipsConfig> __tipsConfig;
+(void)setupTipsConfig:(id<NetTipsConfig>)tipsConfig{
    __tipsConfig = tipsConfig;
}

-(id)resetTipsConfig:(id<NetTipsConfig>)tipsConfig{
    self.tipsConfig = tipsConfig;
    return self;
}

-(id)setLoadMode:(RequestLoad)mode{
    self.needShowLoading = (mode & RequestLoadShowLoading) == RequestLoadShowLoading;
    self.needShowErrorTips = (mode & RequestLoadShowErrorTips) == RequestLoadShowErrorTips;
    self.needShowSuccessTips = (mode & RequestLoadShowSuccessTips) == RequestLoadShowSuccessTips;
    self.isQuiet = (mode & RequestLoadNoStatusLoading) == RequestLoadNoStatusLoading;
    return self;
}

#pragma mark - 请求内容

-(id)requestPath:(NSString *)path withParams:(NSDictionary *)params type:(REQUEST_TYPE)type{
    NetRequestModel *request = [[NetRequestModel alloc] init];
    request.path = path;
    request.params = params;
    request.type = type;
    return self;
}

#pragma mark - 发起请求
- (void)request {
  if (!self.isQuiet) [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    if ([self.delegate respondsToSelector:@selector(requestWillStart)]) {
        [self.delegate requestWillStart];
    }
    
    if (self.needShowLoading && [self.tipsConfig respondsToSelector:@selector(showLoading)]) [self.tipsConfig showLoading];
    
    NSDictionary *params = self.params;
    if ([self respondsToSelector:@selector(requestFinalParamsWithSplicedParams:)]) {
        params = [self requestFinalParamsWithSplicedParams:self.params];
    }else if ([self.config respondsToSelector:@selector(finalRequestObjectWithRequest:)]){
        params = [self.config finalRequestObjectWithRequest:self.params];
    }
    
    switch (self.type) {
        case REQUEST_GET:
        {
            [self.httpManager GET:self.path parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self requestSuccessTask:task responseObject:responseObject];
                [self releaseConfig];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self requestFailureTask:task error:error];
                [self releaseConfig];
            }];
        }
            break;
        case REQUEST_POST:
        {
            [self.httpManager POST:self.path parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self requestSuccessTask:task responseObject:responseObject];
                [self releaseConfig];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self requestFailureTask:task error:error];
                [self releaseConfig];
            }];
        }
            break;
            
        default:
            if (self.needShowLoading && [self.tipsConfig respondsToSelector:@selector(disappearLoading)]) [self.tipsConfig disappearLoading];
            if (!self.isQuiet) [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

            break;
    }
}

-(void)requestCallBack:(void (^)(NetResponseModel *))callBack{
    self.CallBack = callBack;
    [self request];
}

-(void)reRequest{
    [self request];
}

-(void)requestSuccessTask:(NSURLSessionDataTask *)task responseObject:(id)responseObject{
    
    if (self.needShowLoading && [self.tipsConfig respondsToSelector:@selector(disappearLoading)]) [self.tipsConfig disappearLoading];
    if (!self.isQuiet) [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if ([self.delegate respondsToSelector:@selector(requestDidSuccess)]) {
        [self.delegate requestDidSuccess];
    }
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
    
    if ([self.config respondsToSelector:@selector(finalResponseObjectWithResponse:)]) {
        json = [self.config finalResponseObjectWithResponse:json];
    }
    
    if (!json) {
//        NSLog(@"\nsuccess------------------\n%@ \n---------------",task.currentRequest);
        NSString *response = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        if (self.Success) self.Success(response);
        if (self.needShowSuccessTips && [self.tipsConfig respondsToSelector:@selector(showTips:type:)]) [self.tipsConfig showTips:response type:RESPONSE_TIPS_SUCCESS];

    }else{
        
        NSString *tips = json ? [self.config requestMessageWithResponse:json] : nil;
        
        if ([self.config requestIsSuccessWithResponse:json]) {
//        NSLog(@"\nsuccess------------------\n%@ \n---------------",task.currentRequest);
            if (self.Success) self.Success(json);
            if (self.needShowSuccessTips && [self.tipsConfig respondsToSelector:@selector(showTips:type:)]) [self.tipsConfig showTips:tips type:RESPONSE_TIPS_SUCCESS];
            
        }else{
            
            NSLog(@"\nmistake------------------\n%@ \n---------------\n%@\n----------------%@",
                  json,
                  task.currentRequest,
                  tips);
            
            [self.config requestHandleWithErrorCodeWithResponse:json];
            
            if (self.Mistake) self.Mistake(json);
            if (self.Failure) self.Failure(json);
            if (self.needShowErrorTips && [self.tipsConfig respondsToSelector:@selector(showTips:type:)]) [self.tipsConfig showTips:tips type:RESPONSE_TIPS_FAIL];
        }
    }
    
}

-(void)requestFailureTask:(NSURLSessionDataTask *)task error:(NSError *)error{
    
    if (self.needShowLoading && [self.tipsConfig respondsToSelector:@selector(disappearLoading)]) [self.tipsConfig disappearLoading];
    if (!self.isQuiet) [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    if ([self.delegate respondsToSelector:@selector(requestDidFailure)]) {
        [self.delegate requestDidFailure];
    }
    
    NSLog(@"\nlink---------------------\n%@ \n-----------------------\n%@",error,task.currentRequest);
    
    NSDictionary *responseObject = [self.config requestLinkErrorMessageWithError:error response:task.response];
    
    if (self.FailLink) self.FailLink(responseObject);
    if (self.Failure) self.Failure(responseObject);
    
    if (self.needShowErrorTips && [self.tipsConfig respondsToSelector:@selector(showTips:type:)]) [self.tipsConfig showTips:[self.config requestMessageWithResponse:responseObject] type:RESPONSE_TIPS_LINK_FAIL];

}

-(void)requestOnly{
}


#pragma mark - setter getter
-(AFHTTPSessionManager *)httpManager{
    if (!_httpManager) {
        _httpManager = [[AFHTTPSessionManager alloc] init];
        _httpManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        _httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _httpManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html",@"text/plain", nil];
        _httpManager.requestSerializer.timeoutInterval = __timeInterval == 0 ? 15 : __timeInterval;
    }
    return _httpManager;
}

@end
