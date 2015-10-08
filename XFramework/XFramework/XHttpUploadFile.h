//
//  XHttpUploadFile.h
//  XFramework
//
//  Created by XJY on 15/7/28.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>

#define keyForFileData          @"fileData"
#define keyForFileNameWithSufix @"fileNameWithSufix"

@interface XHttpUploadFile : NSObject

typedef void (^UploadProgressBlock)(float newProgress);
typedef void (^UploadFinishBlock)(id responseObject, NSError *error);

/**
 上传文件,传入地址数组
 */
- (void)uploadFile:(NSString *)URLString
        parameters:(NSDictionary *)parameters
       filePathArr:(NSArray *)filePathArr
       contentType:(NSString *)contentType
          mimeType:(NSString *)mimeType
     progressBlock:(UploadProgressBlock)progressBlock
      finshedBlock:(UploadFinishBlock)finishBlock;

/**
 上传文件,传入图片名与data组合成的数组
 */
- (void)uploadFile:(NSString *)URLString
        parameters:(NSDictionary *)parameters
      fileInforArr:(NSArray *)fileInforArr
       contentType:(NSString *)contentType
          mimeType:(NSString *)mimeType
     progressBlock:(UploadProgressBlock)progressBlock
      finshedBlock:(UploadFinishBlock)finishBlock;

@end
