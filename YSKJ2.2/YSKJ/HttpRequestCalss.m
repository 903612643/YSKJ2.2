//
//  AllPersonViewController.h
//  YSKJ
//
//  Created by YSKJ on 16/11/4.
//  Copyright © 2016年 5164casa.com. All rights reserved.
//


#import "HttpRequestCalss.h"

#import "YSKJ_NetStatusNotificationView.h"

#define LOGINURL  @"http://www.5164casa.com/api/app/login/index"

static HttpRequestCalss *stance=nil;

@implementation HttpRequestCalss

+(HttpRequestCalss *)sharnInstance
{
    if (stance==nil) {
        
        stance=[[HttpRequestCalss alloc] init];
        
    }
    return stance;
}

-(AFHTTPSessionManager *)manager
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    // 超时时间
    manager.requestSerializer.timeoutInterval = kTimeOutInterval;
    
    // 声明上传的是json格式的参数，需要你和后台约定好，不然会出现后台无法获取到你上传的参数问题
    manager.requestSerializer = [AFHTTPRequestSerializer serializer]; // 上传普通格式
    //    manager.requestSerializer = [AFJSONRequestSerializer serializer]; // 上传JSON格式
    
    // 声明获取到的数据格式
    manager.responseSerializer = [AFHTTPResponseSerializer serializer]; // AFN不会解析,数据是data，需要自己解析
    //    manager.responseSerializer = [AFJSONResponseSerializer serializer]; // AFN会JSON解析返回的数据
    // 个人建议还是自己解析的比较好，有时接口返回的数据不合格会报3840错误，大致是AFN无法解析返回来的数据
    return manager;
}

//get方法
- (void)getHttpDataWithParam:(NSDictionary *)param url:(NSString*)url  Success:(SuccessBlock)success fail:(AFNErrorBlock)fail
{

    AFHTTPSessionManager *manager = [self manager];
    
    [manager GET:url parameters:param progress:^(NSProgress * _Nonnull downloadProgress) {
        // 这里可以获取到目前数据请求的进度
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        // 请求成功
        if(responseObject){
            
            id json =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];

            //成功调用
            if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(theSuccess:andHttpRequest:)]) {
                
                [self.delegate theSuccess:json andHttpRequest:self];
        
            }
            
            
        } else {
            
            success(@{@"msg":@"暂无数据"}, NO);
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        // 请求失败
        
        //失败调用
        if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(theFail:andHttpRequest:)]) {
            
            [self.delegate theFail:error andHttpRequest:self];
        }

        fail(error);
    }];
    
}

//post
- (void)postHttpDataWithParam:(NSDictionary *)param url:(NSString*)url success:(SuccessBlock)success fail:(AFNErrorBlock)fail
{
    // 创建请求类
    AFHTTPSessionManager *manager = [self manager];
    [manager POST:url parameters:param progress:^(NSProgress * _Nonnull uploadProgress) {
        // 这里可以获取到目前数据请求的进度
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        // 请求成功
        if(responseObject){
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            
            //成功调用
            if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(theSuccess:andHttpRequest:)]) {
                
                [self.delegate theSuccess:dict andHttpRequest:self];
                
            }
            success(dict,YES);
           
            
        } else {
            success(@{@"msg":@"暂无数据"}, NO);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [self.delegate theFail:error andHttpRequest:self];
        
        // 请求失败
        fail(error);
        
    }];
    
}

// 判断网络
-(void)judgeNet:(void (^)(NSInteger statusIndex))block;
{
    self.netManger = [AFNetworkReachabilityManager sharedManager];
    
    __block  NSInteger tempIndex;
    
    [self.netManger setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {

        switch (status) {
                
            case AFNetworkReachabilityStatusNotReachable: {
                
                tempIndex = status;
                
                NSLog(@"网络不可用");
                
              //  [YSKJ_NetStatusNotificationView showNotificationViewWithText:@"当前网络不可用，请检查网络设置"];

                break;
            }
                
            case AFNetworkReachabilityStatusReachableViaWiFi: {
                
                NSLog(@"Wifi已开启");
                
                tempIndex = status;
                
                break;
            }
                
            case AFNetworkReachabilityStatusReachableViaWWAN: {
                
                NSLog(@"你现在使用的流量");
                
                tempIndex = status;
                
                break;
            }
                
            case AFNetworkReachabilityStatusUnknown: {
                
                NSLog(@"你现在使用的未知网络");
                
                //  [YSKJ_NetStatusNotificationView showNotificationViewWithText:@"当前网络不可用，请检查网络设置"];
                
                tempIndex = status;
                
                break;
            }

                
            default:
                break;
        }
        
        block(status);
        
    }];
    
    [self.netManger startMonitoring];
    
}


@end
