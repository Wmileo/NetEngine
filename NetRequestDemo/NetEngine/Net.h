//
//  Net.h
//  NetRequestDemo
//
//  Created by ileo on 16/9/21.
//  Copyright © 2016年 ileo. All rights reserved.
//

#import "NetEngine.h"

//for swift

@protocol NetRequest <NSObject>

#pragma mark - 请求配置

/**
 *  设置超时时间
 */
-(id<NetRequest>)configWithTimeout:(NSTimeInterval)timeInterval;

/**
 *  配置 NetRequestConfig
 */
-(id<NetRequest>)configWithNetRequest:(id<NetRequestConfig>)config;

#pragma mark - 请求提醒配置

/**
 *  配置定制 NetTipsConfig
 */
-(id<NetRequest>)configWithNetTips:(id<NetTipsConfig>)tipsConfig;

/**
 *  配置加载过程
 */
-(id<NetRequest>)configWithLoadShow:(RequestLoad)load;

#pragma mark - 请求内容
/**
 *  请求接口及参数
 *
 *  @param path   请求路径
 *  @param params 请求参数
 *  @param type   请求类型Post，Get
 *
 */
-(id<NetRequest>)requestWithPath:(NSString *)path
                          params:(NSDictionary *)params
                            type:(REQUEST_TYPE)type;

/**
 *  请求接口及参数
 *
 *  @param path   完整请求路径
 *  @param params 完整请求参数
 *  @param type   请求类型Post，Get
 *
 */
-(id<NetRequest>)requestWithFullPath:(NSString *)path
                          fullParams:(NSDictionary *)params
                                type:(REQUEST_TYPE)type;



#pragma mark - 发起请求
/**
 *  基础
 *
 *  @param success  成功
 *  @param failure  失败（包含所有失败）
 *  @param mistake  由自身参数引起的失败
 *  @param link     由网络或服务器引起的失败
 */
-(void)requestWithSuccess:(void (^)(NSDictionary<NSString *, id> *info))success
                  failure:(void (^)(NSDictionary<NSString *, id> *info))failure
              failMistake:(void (^)(NSDictionary<NSString *, id> *info))mistake
                 failLink:(void (^)(NSDictionary<NSString *, id> *info))link;


/**
 *  基础 统一处理错误
 *
 *  @param success  成功
 *  @param failure  失败（包含所有失败）
 */
-(void)requestWithSuccess:(void (^)(NSDictionary<NSString *, id> *info))success
                  failure:(void (^)(NSDictionary<NSString *, id> *info))failure;


/**
 *  只处理成功状态
 *
 *  @param success 成功
 */
-(void)requestWithSuccess:(void (^)(NSDictionary<NSString *, id> *info))success;

/**
 *  只发送请求 不处理返回结果
 */
-(void)requestOnly;

@end

@interface Net : NetEngine <NetRequest>

@end
