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
@property (nonatomic, weak) id<NetConfig> config;
@property (nonatomic, weak) id<NetTipsConfig> tipsConfig;

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
+(void)setupConfig:(id<NetConfig>)config{
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

-(id)configRequest:(NetRequestModel *)request{
    self.requestModel = request;
    return self;
}

#pragma mark - 发起请求
- (void)request {
    
    if ([self respondsToSelector:@selector(requestInfoWillHandleWithEngine:)]) {
        [self requestInfoWillHandleWithEngine:self];
    }
    
    if ([self.config respondsToSelector:@selector(handleRequestInfoWithNetEngine:)]){
        [self.config handleRequestInfoWithNetEngine:self];
    }
    
    if ([self respondsToSelector:@selector(requestWillStartWithNetEngine:)]) {
        [self requestWillStartWithNetEngine:self];
    }
    
    if (!self.isQuiet) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
    
    if (self.needShowLoading && [self.tipsConfig respondsToSelector:@selector(showLoading)]) {
        [self.tipsConfig showLoading];
    }

    switch (self.requestModel.type) {
        case GET:
        {
            [self.httpManager GET:self.requestModel.path parameters:self.requestModel.params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self requestSuccessTask:task responseObject:responseObject];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self requestFailureTask:task error:error];
            }];
        }
            break;
        case POST:
        {
            [self.httpManager POST:self.requestModel.path parameters:self.requestModel.params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self requestSuccessTask:task responseObject:responseObject];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self requestFailureTask:task error:error];
            }];
        }
            break;
            
        default:
        {
            if (self.needShowLoading && [self.tipsConfig respondsToSelector:@selector(disappearLoading)]) [self.tipsConfig disappearLoading];
            if (!self.isQuiet) [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
            break;
    }
}

-(void)requestCallBack:(void (^)(NetResponseModel *))callBack{
    self.CallBack = callBack;
    [self request];
}

-(void)requestSuccessTask:(NSURLSessionDataTask *)task responseObject:(id)responseObject{
    
    if (self.needShowLoading && [self.tipsConfig respondsToSelector:@selector(disappearLoading)]) [self.tipsConfig disappearLoading];
    if (!self.isQuiet) [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NetResponseModel *model = [[NetResponseModel alloc] init];
    model.task = task;
    model.responseObject = responseObject;
    self.responseModel = model;
    
    [self.config handleResponseInfoWithNetEngine:self];
    
    if ([self respondsToSelector:@selector(requestDidSuccessWithNetEngine:)]) {
        [self requestDidSuccessWithNetEngine:self];
    }
    
    if (self.CallBack) {
        self.CallBack(self.responseModel);
    }
    
    if ([self.tipsConfig respondsToSelector:@selector(showTipsWithNetEngine:)]) {
        if ((self.responseModel.success && self.needShowSuccessTips) || (!self.responseModel.success && self.needShowErrorTips)) {
            [self.tipsConfig showTipsWithNetEngine:self];
        }
    }
    
}

-(void)requestFailureTask:(NSURLSessionDataTask *)task error:(NSError *)error{
    
    if (self.needShowLoading && [self.tipsConfig respondsToSelector:@selector(disappearLoading)]) [self.tipsConfig disappearLoading];
    if (!self.isQuiet) [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    NetResponseModel *model = [[NetResponseModel alloc] init];
    model.task = task;
    model.error = error;
    self.responseModel = model;
    
    [self.config handleResponseInfoWithNetEngine:self];
    
    if ([self respondsToSelector:@selector(requestDidFailureWithNetEngine:)]) {
        [self requestDidFailureWithNetEngine:self];
    }
   
    if (self.CallBack) {
        self.CallBack(self.responseModel);
    }
    
    if ([self.tipsConfig respondsToSelector:@selector(showTipsWithNetEngine:)]) {
        if (!self.responseModel.success && self.needShowErrorTips) {
            [self.tipsConfig showTipsWithNetEngine:self];
        }
    }

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
