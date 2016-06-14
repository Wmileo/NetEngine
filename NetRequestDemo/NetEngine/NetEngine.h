//
//  NetEngine.h
//  NetRequestDemo
//
//  Created by ileo on 16/3/28.
//  Copyright © 2016年 ileo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, REQUEST_TYPE){
    REQUEST_POST,//post请求
    REQUEST_GET//get请求
};

#define __SELF [[[self class] alloc] init]

/**
 *  请求配置  －－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
 */
@protocol NetRequestConfig <NSObject>

@required
/**
 *  请求主服务器
 */
-(NSString *)requestMainURL;

#pragma mark - 请求返回操作
/**
 *  判断返回操作是否成功
 */
-(BOOL)requestIsSuccessWithResponse:(id)responseObject;

/**
 *  获取返回的错误信息
 */
-(NSString *)requestFailureMessageWithResponse:(id)responseObject;

/**
 *  处理错误码
 */
-(void)requestHandleWithErrorCodeWithResponse:(id)responseObject;

/**
 *  错误信息
 */
-(NSDictionary *)requestLinkErrorMessage;

@end


/**
 *  请求过程相关tips操作   －－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
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
-(void)showTips:(NSString *)tips;

@end

/**
 *  请求回调  －－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
 */
@protocol NetEngineDelegate <NSObject>

@optional

/**
 *  请求开始时调用
 */
-(void)requestWillStart;

/**
 *  请求成功时调用
 */
-(void)requestDidSuccess;

/**
 *  请求失败时调用
 */
-(void)requestDidFailure;

@end


/**
 *  请求默认配置  －－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
 */
@protocol NetEngineDataSource <NSObject>

@optional
/**
 *  返回默认配置
 */
-(id<NetRequestConfig>)requestDefaultConfig;

/**
 *  请求公共参数
 */
-(NSDictionary *)requestCommonParams;

/**
 *  对拼接后的参数进行处理得到最终请求参数
 */
-(NSDictionary *)requestFinalParamsWithSplicedParams:(NSDictionary *)spliced;


@end


/**  －－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
 *  推荐写法：
 *
 * 一 ，以服务器为划分类
 *  1，配置公共 NetTipsConfig
 *  2，每个请求服务器均继承该类，并配置NetRequestConfig
 *  3，每个请求服务器类作为父类，子类按业务模块写请求
 *  4，每个请求均是类方法
 *
 * 二 ，以业务为划分类
 *  1，配置公共 NetTipsConfig
 *  2，每个业务网络请求模块子类继承该类，实现NetEngineDataSource
 *  3，每个请求请求均是类方法
 *
 */
@interface NetEngine : NSObject <NetEngineDataSource>

#pragma mark - 请求配置
/**
 *  设置超时时间，默认5秒
 */
-(id)requestTimeoutInterval:(NSTimeInterval)timeInterval;

/**
 *  配置类 NetRequestConfig
 */
-(void)requestWithConfig:(id<NetRequestConfig>)config;

#pragma mark - 请求提醒配置
/**
 *  配置公共 NetTipsConfig
 */
+(void)requestWithTipsConfig:(id<NetTipsConfig>)tipsConfig;

/**
 *  配置定制 NetTipsConfig
 */
-(void)requestWithTipsConfig:(id<NetTipsConfig>)tipsConfig;

/**
 *  加载时需要显示动画
 */
-(id)requestNeedShowLoading;

/**
 *  发生错误时需要显示错误提示
 */
-(id)requestNeedShowErrorTips;

/**
 *  请求回调
 */
@property (nonatomic, assign) id<NetEngineDelegate> delegate;

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



@end
