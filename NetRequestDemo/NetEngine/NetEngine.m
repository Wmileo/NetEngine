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

@end


@implementation NetEngine

#pragma mark - setter getter
-(AFHTTPSessionManager *)httpManager{
    if (!_httpManager) {
        _httpManager = [[AFHTTPSessionManager alloc] init];
        _httpManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/plain", nil];
        _httpManager.requestSerializer.timeoutInterval = 5;
    }
    return _httpManager;
}

-(NetEngine *)requestTimeoutInterval:(NSTimeInterval)timeInterval{
    self.httpManager.requestSerializer.timeoutInterval = timeInterval;
    return self;
}

@end
