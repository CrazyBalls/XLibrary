//
//  XHttpRequest.m
//  XFramework
//
//  Created by XJY on 15/7/27.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import "XHttpRequest.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "XTool.h"

@interface XHttpRequest () {
    NSURLConnection     *       urlConnection;
    AFHTTPRequestOperationManager *manager;
    
    NSStringEncoding            responseStringEncoding;
    NSMutableData       *       resultData;
    XHttpRequestFinishedBlock   finishedBlock;
}

@end

@implementation XHttpRequest

- (instancetype)init {
    self = [super init];
    if (self) {
        urlConnection = nil;
        responseStringEncoding = NSUTF8StringEncoding;
        resultData = [[NSMutableData alloc] init];
        finishedBlock = nil;
    }
    return self;
}

- (void)executingFinishedSuccessBlock:(id)responseObject {
    if (finishedBlock) {
        finishedBlock([[NSString alloc] initWithData:responseObject encoding:responseStringEncoding], nil);
    }
}

- (void)executingFinishedFailureBlock:(NSError *)error {
    if (finishedBlock) {
        finishedBlock(nil, error);
    }
}

/********AFNetworking*********/

- (void)afGETRequestWithURL:(NSString *)URLString
            requestEncoding:(NSStringEncoding)requestEncoding
           responseEncoding:(NSStringEncoding)responseEncoding
                    timeout:(NSTimeInterval)timeout
               finshedBlock:(XHttpRequestFinishedBlock)block {
    
    finishedBlock = block;
    
    manager = [self getHTTPRequestOperationManager:requestEncoding responseEncoding:responseEncoding timeout:timeout];
    
    __block XHttpRequest *b_self = self;
    
    [manager GET:URLString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [b_self executingFinishedSuccessBlock:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [b_self executingFinishedFailureBlock:error];
    }];
}

- (void)afPOSTRequestWithURL:(NSString *)URLString
                  parameters:(id)parameters
             requestEncoding:(NSStringEncoding)requestEncoding
            responseEncoding:(NSStringEncoding)responseEncoding
                     timeout:(NSTimeInterval)timeout
                finshedBlock:(XHttpRequestFinishedBlock)block {
    
    finishedBlock = block;
    
    manager = [self getHTTPRequestOperationManager:requestEncoding responseEncoding:responseEncoding timeout:timeout];
    
    __block XHttpRequest *b_self = self;
    
    [manager POST:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [b_self executingFinishedSuccessBlock:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [b_self executingFinishedFailureBlock:error];
    }];
}

- (void)afPUTRequestWithURL:(NSString *)URLString
                 parameters:(id)parameters
            requestEncoding:(NSStringEncoding)requestEncoding
           responseEncoding:(NSStringEncoding)responseEncoding
                    timeout:(NSTimeInterval)timeout
               finshedBlock:(XHttpRequestFinishedBlock)block {
    
    finishedBlock = block;
    
    manager = [self getHTTPRequestOperationManager:requestEncoding responseEncoding:responseEncoding timeout:timeout];
    
    __block XHttpRequest *b_self = self;
    
    [manager PUT:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [b_self executingFinishedSuccessBlock:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [b_self executingFinishedFailureBlock:error];
    }];
}

- (void)afDELETERequestWithURL:(NSString *)URLString
               requestEncoding:(NSStringEncoding)requestEncoding
              responseEncoding:(NSStringEncoding)responseEncoding
                       timeout:(NSTimeInterval)timeout
                  finshedBlock:(XHttpRequestFinishedBlock)block {
    
    finishedBlock = block;
    
    manager = [self getHTTPRequestOperationManager:requestEncoding responseEncoding:responseEncoding timeout:timeout];
    
    __block XHttpRequest *b_self = self;
    
    [manager DELETE:URLString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [b_self executingFinishedSuccessBlock:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [b_self executingFinishedFailureBlock:error];
    }];
}

- (void)afHEADRequestWithURL:(NSString *)URLString
            requestEncoding:(NSStringEncoding)requestEncoding
           responseEncoding:(NSStringEncoding)responseEncoding
                    timeout:(NSTimeInterval)timeout
               finshedBlock:(XHttpRequestFinishedBlock)block {
    
    finishedBlock = block;
    
    manager = [self getHTTPRequestOperationManager:requestEncoding responseEncoding:responseEncoding timeout:timeout];
    
    __block XHttpRequest *b_self = self;
    
    [manager HEAD:URLString parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation) {
        [b_self executingFinishedSuccessBlock:nil];
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        [b_self executingFinishedFailureBlock:error];
    }];
}

- (void)afCancelAllRequest {
    [manager.operationQueue cancelAllOperations];
}

- (AFHTTPRequestOperationManager *)getHTTPRequestOperationManager:(NSStringEncoding)requestEncoding responseEncoding:(NSStringEncoding)responseEncoding timeout:(NSTimeInterval)timeout {
    
    responseStringEncoding = responseEncoding;
    
    manager = [AFHTTPRequestOperationManager manager];
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    [manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    [manager.requestSerializer setStringEncoding:requestEncoding];
    [manager.responseSerializer setStringEncoding:responseEncoding];
    
    if (timeout >= 0) {
        [manager.requestSerializer setTimeoutInterval:timeout];
    }
    return manager;
}

/*****************************/

/************自定义************/

- (BOOL)GETRequestWithURL:(NSString *)URLString
          requestEncoding:(NSStringEncoding)requestEncoding
         responseEncoding:(NSStringEncoding)responseEncoding
                  timeout:(NSTimeInterval)timeout
             finshedBlock:(XHttpRequestFinishedBlock)block {
    return [self requestWithURL:URLString
                         method:@"GET"
                     parameters:nil
                requestEncoding:requestEncoding
               responseEncoding:responseEncoding
                        timeout:timeout
                   finshedBlock:block];
}

- (BOOL)POSTRequestWithURL:(NSString *)URLString
                parameters:(NSString *)parameters
           requestEncoding:(NSStringEncoding)requestEncoding
          responseEncoding:(NSStringEncoding)responseEncoding
                   timeout:(NSTimeInterval)timeout
              finshedBlock:(XHttpRequestFinishedBlock)block {
    return [self requestWithURL:URLString
                         method:@"POST"
                     parameters:parameters
                requestEncoding:requestEncoding
               responseEncoding:responseEncoding
                        timeout:timeout
                   finshedBlock:block];
}

- (BOOL)requestWithURL:(NSString *)URLString
                method:(NSString *)method
            parameters:(NSString *)parameters
       requestEncoding:(NSStringEncoding)requestEncoding
      responseEncoding:(NSStringEncoding)responseEncoding
               timeout:(NSTimeInterval)timeout
          finshedBlock:(XHttpRequestFinishedBlock)block {
    
    responseStringEncoding = responseEncoding;
    finishedBlock = block;
    
    URLString = [URLString stringByAddingPercentEscapesUsingEncoding:requestEncoding];
    
    NSURL *url = [NSURL URLWithString:URLString];
    NSMutableURLRequest *requset = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:timeout];
    
    [requset setHTTPMethod:method];
    
    if ([XTool isStringEmpty:parameters] == NO) {
        parameters = [parameters stringByAddingPercentEscapesUsingEncoding:requestEncoding];
        [requset setHTTPBody:[parameters dataUsingEncoding:requestEncoding]];
    } else {
        [requset setHTTPBody:nil];
    }
    
    urlConnection = [[NSURLConnection alloc] initWithRequest:requset delegate:self];
    
    if (urlConnection) {
        return YES;
    } else {
        return NO;
    }
}

/**
 取消请求
 */
- (void)cancelRequest {
    [urlConnection cancel];
}

/**
 接收到服务器回应的时回调
 */
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if (resultData != nil) {
        [resultData setLength:0];
    } else {
        resultData = [[NSMutableData alloc] init];
    }
    
    if ([response respondsToSelector:@selector(allHeaderFields)]) {
        NSDictionary *dic = httpResponse.allHeaderFields;
        NSArray *arr =[[dic objectForKey:@"Content-Type"] componentsSeparatedByString:NSLocalizedString(@"=", nil)];
        if([[arr lastObject] caseInsensitiveCompare:@"GBK"] == NSOrderedSame) {
            responseStringEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        } else if([[arr lastObject] caseInsensitiveCompare:@"UTF-8"] == NSOrderedSame) {
            responseStringEncoding = NSUTF8StringEncoding;
        } else {
            responseStringEncoding = NSASCIIStringEncoding;
        }
    }
}

/**
 接收到服务器传输数据的时候调用,此方法根据数据大小执行若干次
 */
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [resultData appendData:data];
}

/**
 数据传完之后调用此方法
 */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self executingFinishedSuccessBlock:resultData];
}

/**
 网络请求过程中,出现任何错误(断网,连接超时等)会进入此方法
 */
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self executingFinishedFailureBlock:error];
}

/*****************************/

@end
