//
//  NetModel.h
//  NetRequestDemo
//
//  Created by leo on 2017/1/13.
//  Copyright © 2017年 ileo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetModel : NSObject

@property (nonatomic, assign) BOOL success;//是否成功
@property (nonatomic, copy) NSString *message;//返回信息
@property (nonatomic, copy) NSString *code;//返回状态码
@property (nonatomic, copy) NSDictionary *data;//返回客户端数据

@end
