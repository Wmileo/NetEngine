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

@property (nonatomic, strong) AFHTTPSessionManager *httpManager;

@property (nonatomic, assign) NSTimeInterval timeoutInterval;

#pragma mark - 请求内容
@property (nonatomic, strong) id<NetRequestConfig> config;
@property (nonatomic, strong) id<NetTipsConfig> tipsConfig;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, assign) REQUEST_TYPE type;
@property (nonatomic, copy) NSDictionary *params;

#pragma mark - 请求提示
@property (nonatomic, assign) BOOL needShowLoading;
@property (nonatomic, assign) BOOL needShowErrorTips;
@property (nonatomic, assign) BOOL needShowSuccessTips;
@property (nonatomic, assign) BOOL isQuiet;

#pragma mark - callback
@property (nonatomic, copy) void (^Success)(id json);
@property (nonatomic, copy) void (^Failure)(id json);
@property (nonatomic, copy) void (^Mistake)(id json);
@property (nonatomic, copy) void (^FailLink)(id json);

@end

@implementation NetEngine

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        if (__tipsConfig) {
            [self requestWithTipsConfig:__tipsConfig];
        }
        
        if ([self respondsToSelector:@selector(requestDefaultConfig)]) {
            [self requestWithConfig:[self performSelector:@selector(requestDefaultConfig)]];
        }else if (__requestConfig) {
            [self requestWithConfig:__requestConfig];
        }
        
    }
    return self;
}

-(void)releaseConfig{
    self.config = nil;
    self.tipsConfig = nil;
}

#pragma mark - 请求配置
static NSTimeInterval __timeInterval;
+(void)setupTimeoutInterval:(NSTimeInterval)timeInterval{
    __timeInterval = timeInterval;
}

-(id)requestTimeoutInterval:(NSTimeInterval)timeInterval{
    self.httpManager.requestSerializer.timeoutInterval = timeInterval;
    return self;
}

static id<NetRequestConfig> __requestConfig;
+(void)setupDefaultConfig:(id<NetRequestConfig>)config{
    __requestConfig = config;
}

-(id)requestWithConfig:(id<NetRequestConfig>)config{
    self.config = config;
    return self;
}

#pragma mark - 请求提醒配置
static id<NetTipsConfig> __tipsConfig;
+(void)setupDefaultTipsConfig:(id<NetTipsConfig>)tipsConfig{
    __tipsConfig = tipsConfig;
}

-(id)requestWithTipsConfig:(id<NetTipsConfig>)tipsConfig{
    self.tipsConfig = tipsConfig;
    return self;
}

-(id)requestWithLoad:(RequestLoad)load{
    self.needShowLoading = (load & RequestLoadShowLoading) == RequestLoadShowLoading;
    self.needShowErrorTips = (load & RequestLoadShowErrorTips) == RequestLoadShowErrorTips;
    self.needShowSuccessTips = (load & RequestLoadShowSuccessTips) == RequestLoadShowSuccessTips;
    self.isQuiet = (load & RequestLoadNoStatusLoading) == RequestLoadNoStatusLoading;
    return self;
}

#pragma mark - 请求内容
-(id)request:(NSString *)path withParams:(NSDictionary *)params type:(REQUEST_TYPE)type{
    self.path = [NSString stringWithFormat:@"%@%@",[self.config requestMainURL],path];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:params];
    if ([self respondsToSelector:@selector(requestCommonParams)]) {
        [dic addEntriesFromDictionary:[self performSelector:@selector(requestCommonParams)]];
    }
    self.params = [dic copy];
    self.type = type;
    return self;
}

-(id)requestFullPath:(NSString *)path withFullParams:(NSDictionary *)params type:(REQUEST_TYPE)type{
    self.config = nil;
    self.path = path;
    self.params = params;
    self.type = type;
    return self;
}

#pragma mark - 发起请求
-(void)requestSuccess:(void (^)(id))success failure:(void (^)(id))failure failMistake:(void (^)(id))mistake failLink:(void (^)(id))link{
    
    self.Success = success;
    self.Failure = failure;
    self.Mistake = mistake;
    self.FailLink = link;
    
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

-(void)requestSuccess:(void (^)(id))success failure:(void (^)(id))failure{
    [self requestSuccess:success failure:failure failMistake:nil failLink:nil];
}

-(void)requestSuccess:(void (^)(id))success{
    [self requestSuccess:success failure:nil failMistake:nil failLink:nil];
}

-(void)requestOnly{
    [self requestSuccess:nil failure:nil failMistake:nil failLink:nil];
}


#pragma mark - setter getter
-(AFHTTPSessionManager *)httpManager{
    if (!_httpManager) {
        _httpManager = [[AFHTTPSessionManager alloc] init];
        _httpManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        _httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _httpManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html",@"text/plain", nil];
        _httpManager.requestSerializer.timeoutInterval = __timeInterval == 0 ? 15 : __timeInterval;
        if ([self.config respondsToSelector:@selector(configAFHTTPSessionManager:)]) {
            [self.config configAFHTTPSessionManager:_httpManager];
        }
    }
    return _httpManager;
}

@end
