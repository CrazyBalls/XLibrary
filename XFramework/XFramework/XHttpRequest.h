//
//  XHttpRequest.h
//  XFramework
//
//  Created by XJY on 15/7/27.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XHttpRequest : NSObject<NSURLConnectionDataDelegate>

typedef void (^XHttpRequestFinishedBlock)(NSString *requestResult, NSError *error);

/********AFNetworking*********/

- (void)afGETRequestWithURL:(NSString *)URLString
            requestEncoding:(NSStringEncoding)requestEncoding
           responseEncoding:(NSStringEncoding)responseEncoding
                    timeout:(NSTimeInterval)timeout
               finshedBlock:(XHttpRequestFinishedBlock)block;

- (void)afPOSTRequestWithURL:(NSString *)URLString
                  parameters:(id)parameters
             requestEncoding:(NSStringEncoding)requestEncoding
            responseEncoding:(NSStringEncoding)responseEncoding
                     timeout:(NSTimeInterval)timeout
                finshedBlock:(XHttpRequestFinishedBlock)block;

- (void)afPUTRequestWithURL:(NSString *)URLString
                 parameters:(id)parameters
            requestEncoding:(NSStringEncoding)requestEncoding
           responseEncoding:(NSStringEncoding)responseEncoding
                    timeout:(NSTimeInterval)timeout
               finshedBlock:(XHttpRequestFinishedBlock)block;

- (void)afDELETERequestWithURL:(NSString *)URLString
               requestEncoding:(NSStringEncoding)requestEncoding
              responseEncoding:(NSStringEncoding)responseEncoding
                       timeout:(NSTimeInterval)timeout
                  finshedBlock:(XHttpRequestFinishedBlock)block;

- (void)afHEADRequestWithURL:(NSString *)URLString
             requestEncoding:(NSStringEncoding)requestEncoding
            responseEncoding:(NSStringEncoding)responseEncoding
                     timeout:(NSTimeInterval)timeout
                finshedBlock:(XHttpRequestFinishedBlock)block;

- (void)afCancelAllRequest;

/*****************************/

/************自定义************/

- (BOOL)requestWithURL:(NSString *)URLString
                method:(NSString *)method
            parameters:(NSString *)parameters
       requestEncoding:(NSStringEncoding)requestEncoding
      responseEncoding:(NSStringEncoding)responseEncoding
               timeout:(NSTimeInterval)timeout
          finshedBlock:(XHttpRequestFinishedBlock)block;

- (BOOL)GETRequestWithURL:(NSString *)URLString
          requestEncoding:(NSStringEncoding)requestEncoding
         responseEncoding:(NSStringEncoding)responseEncoding
                  timeout:(NSTimeInterval)timeout
             finshedBlock:(XHttpRequestFinishedBlock)block;

- (BOOL)POSTRequestWithURL:(NSString *)URLString
                parameters:(NSString *)parameters
           requestEncoding:(NSStringEncoding)requestEncoding
          responseEncoding:(NSStringEncoding)responseEncoding
                   timeout:(NSTimeInterval)timeout
              finshedBlock:(XHttpRequestFinishedBlock)block;

- (void)cancelRequest;

/*****************************/

@end
