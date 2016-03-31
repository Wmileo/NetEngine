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
    REQUEST_GET//getq
};

#define __SELF [[[self class] alloc] init]



@protocol NetEngineDelegate <NSObject>

-(NSString *)mainURL;
-(NSDictionary *)commonParams;

-(void)requestStart;
-(void)requestSuccess;
-(void)requestFailure;

@end




@interface NetEngine : NSObject

#pragma mark - 请求配置
/**
 *  设置超时时间，默认5秒
 */
-(NetEngine *)requestTimeoutInterval:(NSTimeInterval)timeInterval;



#pragma mark - 请求内容
/**
 *  请求接口及参数
 *
 *  @param path   请求路径
 *  @param params 请求参数
 *  @param type   请求类型Post，Get
 *
 *  可重写
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
 *  可重写
 */
-(id)requestFullPath:(NSString *)path
      withFullParams:(NSDictionary *)params
                type:(REQUEST_TYPE)type;



#pragma mark - 发起请求
/**
 *  基础 可定制
 *
 *  @param showLoad 是否显示等待状态
 *  @param showTips 是否显示错误提示弹出框
 *  @param success  成功
 *  @param failure  失败（包含所有失败）
 *  @param mistake  由自身参数引起的失败
 *  @param link     由网络或服务器引起的失败
 */
-(void)requestShowLoading:(BOOL)showLoad
            showErrorTips:(BOOL)showTips
                  success:(void (^)(id JSON))success
                  failure:(void (^)(id JSON))failure
              failMistake:(void (^)(id JSON))mistake
                 failLink:(void (^)(id JSON))link;


/**
 *  基础 统一处理错误 可定制
 *
 *  @param showLoad 是否显示等待状态
 *  @param showTips 是否显示错误提示弹出框
 *  @param success  成功
 *  @param failure  失败（包含所有失败）
 */
-(void)requestShowLoading:(BOOL)showLoad
            showErrorTips:(BOOL)showTips
                  success:(void (^)(id JSON))success
                  failure:(void (^)(id JSON))failure;


/**
 *  显示等待状态和错误提示 处理成功和失败
 *
 *  @param success 成功
 *  @param failure 失败
 */
-(void)requestShowLoadingAndErrorTipsSuccess:(void (^)(id JSON))success
                                     failure:(void (^)(id JSON))failure;

/**
 *  显示等待状态和错误提示 只处理成功状态
 *
 *  @param success 成功
 */
-(void)requestShowLoadingAndErrorTipsSuccess:(void (^)(id JSON))success;

/**
 *  不显示任何状态 只处理成功状态
 *
 *  @param success 成功
 */
-(void)requestSuccess:(void (^)(id JSON))success;

/**
 *  不显示任何状态 处理成功和失败
 *
 *  @param success 成功
 *  @param failure 失败
 */
-(void)requestSuccess:(void (^)(id JSON))success
              failure:(void (^)(id JSON))failure;



@end
