//
//  NetModel.h
//  NetRequestDemo
//
//  Created by leo on 2017/1/13.
//  Copyright © 2017年 ileo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetModel : NSObject

@end

typedef NS_ENUM(NSInteger, RESPONSE_TYPE){
    RESPONSE_SUCCESS,//返回成功
    RESPONSE_FAIL,//返回失败
    RESPONSE_LINK_FAIL//请求失败
};



@interface NetResponseModel : NSObject

@property (nonatomic, assign) BOOL success;//是否成功
@property (nonatomic, copy) NSString *message;//返回信息
@property (nonatomic, copy) NSString *code;//返回状态码
@property (nonatomic, copy) NSDictionary *data;//返回业务数据
@property (nonatomic, assign) RESPONSE_TYPE response;//返回结果类型

@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) id responseObject;

@property (nonatomic, readonly) NSInteger statusCode;
@property (nonatomic, readonly) NSDictionary *allHeaderFields;

@end

typedef NS_ENUM(NSInteger, REQUEST_TYPE){
    POST,
    GET,
};

@interface NetRequestModel : NSObject

@property (nonatomic, assign) REQUEST_TYPE type;//请求方法
@property (nonatomic, copy) NSString *path;//最终请求路径
@property (nonatomic, copy) NSDictionary *params;//最终请求参数

-(void)addParams:(NSDictionary *)params;

@end

