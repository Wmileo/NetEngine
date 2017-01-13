//
//  NetEngine.h
//  NetRequestDemo
//
//  Created by ileo on 16/3/28.
//  Copyright © 2016年 ileo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"


typedef NS_ENUM(NSInteger, REQUEST_TYPE){
    REQUEST_POST,//post请求
    REQUEST_GET,//get请求
};

typedef NS_ENUM(NSInteger, RESPONSE_TIPS_TYPE){
    RESPONSE_TIPS_SUCCESS,//返回成功
    RESPONSE_TIPS_FAIL,//返回失败
    RESPONSE_TIPS_LINK_FAIL//请求失败
};

typedef NS_ENUM(NSInteger, RequestLoad){
    RequestLoadNone            = 0,       //默认显示状态栏加载
    RequestLoadShowLoading     = 1 << 0,  //显示加载动画
    RequestLoadShowErrorTips   = 1 << 1,  //显示错误提示
    RequestLoadShowSuccessTips = 1 << 2,  //显示成功提示
    RequestLoadNoStatusLoading = 1 << 3   //不显示状态栏加载
};

#define __SELF [[[self class] alloc] init]

@class NetEngine;

/**
 *  请求配置  －－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
 */
@protocol NetRequestConfig <NSObject>

@required
/**
 *  请求主服务器
 */
-(NSString *)mainURL;

#pragma mark - 请求返回操作
/**
 *  判断返回操作是否成功
 */
-(BOOL)isSuccessWithNetEngine:(NetEngine *)netEngine;

/**
 *  获取返回的信息
 */
-(NSString *)messageWithNetEngine:(NetEngine *)netEngine;

/**
 *  处理错误码
 */
-(void)handleErrorWithNetEngine:(NetEngine *)netEngine;

/**
 *  链接错误信息
 */
-(NSDictionary *)linkErrorMessageWithNetEngine:(NetEngine *)netEngine;

-(void)responseInfoWithNetEngine:(NetEngine *) fillInfo:()

@optional
/**
 *  对AFHTTPSessionManager进行配置
 */
-(void)configAFHTTPSessionManager:(AFHTTPSessionManager *)httpManager;

/**
 *  返回业务数据
 */
-(NSDictionary *)responseObjectWithNetEngine:(NetEngine *)netEngine;

/**
 *  对请求参数进行处理
 */
-(NSDictionary *)requestObjectWithNetEngine:(NetEngine *)netEngine;

@end


/**
 *  请求过程相关tips操作   －－－－－－－－－－－－－－－－－－－－－－－－－
 */
@protocol NetTipsConfig <NSObject>

@optional

/**
 *  加载动画显示，没实现的话就没有任何提示
 */
-(void)showLoading;

/**
 *  加载动画消失，没实现的话就没有任何提示
 */
-(void)disappearLoading;

/**
 *  显示提示信息，没实现的话就没有任何提示
 */
-(void)showTips:(NSString *)tips type:(RESPONSE_TIPS_TYPE)type;

@end

/**
 *  请求回调  －－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
 */
@protocol NetEngineDelegate <NSObject>

@optional

/**
 *  请求开始时调用
 */
-(void)requestWillStartWithNetEngine:(NetEngine *)netEngine;

/**
 *  请求成功时调用
 */
-(void)requestDidSuccessWithNetEngine:(NetEngine *)netEngine;

/**
 *  请求失败时调用
 */
-(void)requestDidFailureWithNetEngine:(NetEngine *)netEngine;

@end


/**
 *  请求默认配置  －－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
 */
@protocol NetEngineDataSource <NSObject>

@optional
/**
 *  返回默认配置
 */
-(id<NetRequestConfig>)defaultConfig;

/**
 *  请求公共参数
 */
-(NSDictionary *)commonParams;

/**
 *  对拼接后的参数进行处理得到最终请求参数
 */
-(NSDictionary *)requestFinalParamsWithSplicedParams:(NSDictionary *)spliced netEngine:(NetEngine *)netEngine;

#warning 最终url


@end


@interface NetEngine : NSObject <NetEngineDataSource>

#pragma mark - 请求配置
/**
 *  设置全局超时时间，默认15秒
 */
+(void)setupTimeoutInterval:(NSTimeInterval)timeInterval;

/**
 *  设置超时时间
 */
-(id)requestTimeoutInterval:(NSTimeInterval)timeInterval;

/**
 *  配置全局 NetRequestConfig
 */
+(void)setupDefaultConfig:(id<NetRequestConfig>)config;

/**
 *  配置 NetRequestConfig
 */
-(id)requestWithConfig:(id<NetRequestConfig>)config;

#pragma mark - 请求提醒配置
/**
 *  配置全局 NetTipsConfig
 */
+(void)setupDefaultTipsConfig:(id<NetTipsConfig>)tipsConfig;

/**
 *  配置定制 NetTipsConfig
 */
-(id)requestWithTipsConfig:(id<NetTipsConfig>)tipsConfig;

/**
 *  配置加载过程
 */
-(id)requestWithLoad:(RequestLoad)load;

/**
 *  请求回调
 */
@property (nonatomic, weak) id<NetEngineDelegate> delegate;

#pragma mark - 请求内容
/**
 *  请求接口及参数
 *
 *  @param path   请求路径
 *  @param params 请求参数
 *  @param type   请求类型Post，Get
 *
 */
-(id)request:(NSString *)path
  withParams:(NSDictionary *)params
        type:(REQUEST_TYPE)type;

/**
 *  请求接口及参数
 *
 *  @param path   完整请求路径
 *  @param params 完整请求参数
 *  @param type   请求类型Post，Get
 *
 */
-(id)requestFullPath:(NSString *)path
      withFullParams:(NSDictionary *)params
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
-(void)requestSuccess:(void (^)(id JSON))success
              failure:(void (^)(id JSON))failure
          failMistake:(void (^)(id JSON))mistake
             failLink:(void (^)(id JSON))link;


/**
 *  基础 统一处理错误
 *
 *  @param success  成功
 *  @param failure  失败（包含所有失败）
 */
-(void)requestSuccess:(void (^)(id JSON))success
              failure:(void (^)(id JSON))failure;


/**
 *  只处理成功状态
 *
 *  @param success 成功
 */
-(void)requestSuccess:(void (^)(id JSON))success;

/**
 *  只发送请求 不处理返回结果
 */
-(void)requestOnly;

/**
 *  再次发起请求
 */
-(void)reRequest;

@end
