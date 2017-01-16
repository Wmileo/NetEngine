//
//  NetQB.h
//  NetRequestDemo
//
//  Created by leo on 2017/1/16.
//  Copyright © 2017年 ileo. All rights reserved.
//

#import "NetEngine.h"

@interface QBRequest : NetRequestModel

@property (nonatomic, copy) NSDictionary *postParams;

+(NetRequestModel *)requestWithPath:(NSString *)path params:(NSDictionary *)params;

+(QBRequest *)postPath:(NSString *)path params:(NSDictionary *)params;

@end

@interface NetQB : NetEngine <NetConfig>

+(void)testCallBack:(void(^)(NetResponseModel *model))callback;

@end
