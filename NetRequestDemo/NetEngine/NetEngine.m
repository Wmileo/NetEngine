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
@property (nonatomic, assign) id<NetRequestConfig> config;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, assign) REQUEST_TYPE type;
@property (nonatomic, copy) NSDictionary *params;

#pragma mark - 请求提示
@property (nonatomic, assign) BOOL needShowLoading;
@property (nonatomic, assign) BOOL needShowErrorTips;

@end

@implementation NetEngine

#pragma mark - 请求配置
-(id)requestTimeoutInterval:(NSTimeInterval)timeInterval{
    self.httpManager.requestSerializer.timeoutInterval = timeInterval;
    return self;
}

-(id)requestWithConfig:(id<NetRequestConfig>)config{
    self.config = config;
    return self;
}

-(id)requestNeedShowLoading{
    self.needShowLoading = YES;
    return self;
}

-(id)requestNeedShowErrorTips{
    self.needShowErrorTips = YES;
    return self;
}

#pragma mark - 请求内容
-(id)request:(NSString *)path withParams:(NSDictionary *)params type:(REQUEST_TYPE)type{
    self.path = [NSString stringWithFormat:@"%@%@",[self.config requestMainURL],path];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:params];
    [dic addEntriesFromDictionary:[self.config requestCommonParams]];
    self.params = [dic copy];
    self.type = type;
    return self;
}

-(id)requestFullPath:(NSString *)path withFullParams:(NSDictionary *)params type:(REQUEST_TYPE)type{
    self.path = path;
    self.params = params;
    self.type = type;
    return self;
}

#pragma mark - 发起请求
-(void)requestSuccess:(void (^)(id))success failure:(void (^)(id))failure failMistake:(void (^)(id))mistake failLink:(void (^)(id))link{
    
    if ([self.delegate respondsToSelector:@selector(requestWillStart)]) {
        [self.delegate requestWillStart];
    }
    
    if (self.needShowLoading) [self.config showLoading];
    
    switch (self.type) {
        case REQUEST_GET:
        {
            [self.httpManager GET:self.path parameters:self.params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self requestSuccessTask:task responseObject:responseObject success:success failure:failure failMistake:mistake];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self requestFailureTask:task error:error failure:failure failLink:link];
            }];
        }
            break;
        case REQUEST_POST:
        {
            [self.httpManager POST:self.path parameters:self.params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self requestSuccessTask:task responseObject:responseObject success:success failure:failure failMistake:mistake];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self requestFailureTask:task error:error failure:failure failLink:link];
            }];
        }
            break;
            
        default:
            if (self.needShowLoading) [self.config disappearLoading];
            break;
    }
}

-(void)requestSuccessTask:(NSURLSessionDataTask *)task responseObject:(id)responseObject success:(void(^)(id JSON))success failure:(void (^)(id))failure failMistake:(void (^)(id))mistake{
    if ([self.delegate respondsToSelector:@selector(requestDidSuccess)]) {
        [self.delegate requestDidSuccess];
    }
    
    if ([self.config requestIsSuccessWithResponse:responseObject]) {
        NSLog(@"\nsuccess------------------\n%@ \n---------------",task.currentRequest);
        if (success) success(responseObject);
    }else{
        
        NSString *tips = [self.config requestFailureMessageWithResponse:responseObject];
        NSLog(@"\nmistake------------------\n%@ \n---------------\n%@\n----------------%@",
              responseObject,
              task.currentRequest,
              tips);
        
        [self.config requestHandleWithErrorCodeWithResponse:responseObject];
        
        if (mistake) mistake(responseObject);
        if (failure) failure(responseObject);
        if (self.needShowErrorTips) [self.config showTips:tips];
    }
    
    if (self.needShowLoading) [self.config disappearLoading];
}

-(void)requestFailureTask:(NSURLSessionDataTask *)task error:(NSError *)error failure:(void (^)(id))failure failLink:(void (^)(id))link{
    if ([self.delegate respondsToSelector:@selector(requestDidFailure)]) {
        [self.delegate requestDidFailure];
    }

    NSLog(@"\nlink---------------------\n%@ \n-----------------------\n%@",error,task.currentRequest);
    
    NSDictionary *responseObject = [self.config requestLinkErrorMessage];
    
    if (link) link(responseObject);
    if (failure) failure(responseObject);
    
    if (self.needShowLoading) [self.config disappearLoading];
    if (self.needShowErrorTips) [self.config showTips:[self.config requestFailureMessageWithResponse:responseObject]];
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
        _httpManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/plain", nil];
        _httpManager.requestSerializer.timeoutInterval = 5;
    }
    return _httpManager;
}





@end
