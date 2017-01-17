//
//  NetEngine.h
//  NetRequestDemo
//
//  Created by ileo on 16/3/28.
//  Copyright © 2016年 ileo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"
#import "NetModel.h"

typedef NS_ENUM(NSInteger, RequestLoad){
    RequestLoadNone            = 0,       //默认显示状态栏加载
    RequestLoadShowLoading     = 1 << 0,  //显示加载动画
    RequestLoadShowErrorTips   = 1 << 1,  //显示错误提示
    RequestLoadShowSuccessTips = 1 << 2,  //显示成功提示
    RequestLoadNoStatusLoading = 1 << 3   //不显示状态栏加载
};

#define __SELF [[[self class] alloc] init]

/**
 *  请求配置  －－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
 */
@protocol NetConfig <NSObject>

@required

/**
 *  返回数据处理
 */
-(void)handleResponseInfoWithNetEngine:(id)engine;

@optional
/**
 *  请求数据处理
 */
-(void)handleRequestInfoWithNetEngine:(id)engine;

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
-(void)showTipsWithNetEngine:(id)engine;

@end

/**
 *  请求回调  －－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
 */
@protocol NetEngineDelegate <NSObject>

@optional
/**
 *  请求数据处理前调用
 */
-(void)requestInfoWillHandleWithEngine:(id)engine;

/**
 *  请求开始时调用
 */
-(void)requestWillStartWithNetEngine:(id)engine;

/**
 *  请求成功时调用
 */
-(void)requestDidSuccessWithNetEngine:(id)engine;

/**
 *  请求失败时调用
 */
-(void)requestDidFailureWithNetEngine:(id)engine;

@end


@interface NetEngine : NSObject <NetEngineDelegate>

@property (nonatomic, strong) NetResponseModel *responseModel;
@property (nonatomic, strong) NetRequestModel *requestModel;

@property (nonatomic, strong) AFHTTPSessionManager *httpManager;

#pragma mark - 请求配置
/**
 *  设置全局超时时间，默认15秒
 */
+(void)setupTimeoutInterval:(NSTimeInterval)timeInterval;

/**
 *  设置超时时间
 */
-(id)resetTimeout:(NSTimeInterval)timeInterval;

/**
 *  配置全局 NetRequestConfig
 */
+(void)setupConfig:(id<NetConfig>)config;

/**
 *  配置 NetRequestConfig
 */
-(id)resetConfig:(id<NetConfig>)config;

#pragma mark - 请求提醒配置
/**
 *  配置全局 NetTipsConfig
 */
+(void)setupTipsConfig:(id<NetTipsConfig>)tipsConfig;

/**
 *  配置定制 NetTipsConfig
 */
-(id)resetTipsConfig:(id<NetTipsConfig>)tipsConfig;

/**
 *  配置加载过程
 */
-(id)setLoadMode:(RequestLoad)mode;

/**
 *  配置请求参数
 */
-(id)configRequest:(NetRequestModel *)request;

#pragma mark - 发起请求
/**
 *  配置callback 发送请求
 */
-(void)requestCallBack:(void (^)(NetResponseModel *model))callBack;

/**
 *  发起请求
 */
-(void)request;

@end
