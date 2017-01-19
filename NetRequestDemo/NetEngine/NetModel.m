//
//  NetModel.m
//  NetRequestDemo
//
//  Created by leo on 2017/1/13.
//  Copyright © 2017年 ileo. All rights reserved.
//

#import "NetModel.h"

@implementation NetModel

@end

@implementation NetResponseModel

-(NSInteger)statusCode{
    return ((NSHTTPURLResponse *)self.task.response).statusCode;
}

-(NSDictionary *)allHeaderFields{
    return ((NSHTTPURLResponse *)self.task.response).allHeaderFields;
}

-(NSString *)description{
    return [NSString stringWithFormat:@"\nsuccess:%zd\ncode:%@\nmessage:%@\ndata:%@\nerror:%@\nstatusCode:%zd\nheader:%@",self.success,self.code,self.message,self.data,self.error,self.statusCode,self.allHeaderFields];
}

@end


@implementation NetRequestModel

-(void)addParams:(NSDictionary *)params{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:self.params];
    [dic addEntriesFromDictionary:params];
    self.params = [dic copy];
}

-(NSString *)description{
    return [NSString stringWithFormat:@"\npath:%@\nparams:%@",self.path,self.params];
}

@end
