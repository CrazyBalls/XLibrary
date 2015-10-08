//
//  XHttpUploadFile.m
//  XFramework
//
//  Created by XJY on 15/7/28.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import "XHttpUploadFile.h"
#import "AFHTTPRequestOperationManager.h"
#import "XFileManager.h"

@interface XHttpUploadFile () {
    UploadProgressBlock uploadProgressBlock;
    UploadFinishBlock   uploadFinishBlock;
}
@end

@implementation XHttpUploadFile

- (void)uploadFile:(NSString *)URLString
        parameters:(NSDictionary *)parameters
       filePathArr:(NSArray *)filePathArr
      contentType:(NSString *)contentType
          mimeType:(NSString *)mimeType
     progressBlock:(UploadProgressBlock)progressBlock
      finshedBlock:(UploadFinishBlock)finishBlock {
    
    uploadFinishBlock = finishBlock;
    uploadProgressBlock = progressBlock;
    
    [self requestWithUrl:URLString parameters:parameters contentType:contentType fileBlock:^(id<AFMultipartFormData> fileForm) {
        if ([filePathArr count] > 0) {
            for (NSString *filePath in filePathArr) {
                NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
                NSString *fileNameWithoutSufix = [XFileManager getFileNameWithoutSufixForPath:filePath];
                NSString *fileNameWithSufix = [XFileManager getFileNameWithSufixForPath:filePath];
                if(data) {
                    [fileForm appendPartWithFileData:data name:fileNameWithoutSufix fileName:fileNameWithSufix mimeType:mimeType];
                }
            }
        }
    }];
}

- (void)uploadFile:(NSString *)URLString
        parameters:(NSDictionary *)parameters
      fileInforArr:(NSArray *)fileInforArr
       contentType:(NSString *)contentType
          mimeType:(NSString *)mimeType
     progressBlock:(UploadProgressBlock)progressBlock
      finshedBlock:(UploadFinishBlock)finishBlock {
    
    uploadFinishBlock = finishBlock;
    uploadProgressBlock = progressBlock;
    
    [self requestWithUrl:URLString parameters:parameters contentType:contentType fileBlock:^(id<AFMultipartFormData> fileForm) {
        if (fileInforArr.count > 0) {
            for (NSDictionary *fileInforDic in fileInforArr) {
                NSData *fileData = [fileInforDic objectForKey:keyForFileData];
                NSString *fileNameWithSufix = [fileInforDic objectForKey:keyForFileNameWithSufix];
                NSString *fileNameWithoutSufix = [XFileManager getFileNameWithoutSufixForName:fileNameWithSufix];
                if(fileData) {
                    [fileForm appendPartWithFileData:fileData name:fileNameWithoutSufix fileName:fileNameWithSufix mimeType:mimeType];
                }
            }
        }
    }];
}

- (void)requestWithUrl:(NSString *)URLString
            parameters:(NSDictionary *)parameters
           contentType:(NSString *)contentType
             fileBlock:(void(^)(id<AFMultipartFormData> fileForm))fileBlock {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObject:contentType]];
    [manager.requestSerializer setTimeoutInterval:60];
    AFHTTPRequestOperation *requestOperation = [manager POST:URLString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        fileBlock(formData);
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (uploadFinishBlock) {
            uploadFinishBlock(responseObject, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (uploadFinishBlock) {
            uploadFinishBlock(nil, error);
        }
    }];
    
    [requestOperation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        if (uploadProgressBlock) {
            uploadProgressBlock(totalBytesWritten * 1.0 / totalBytesExpectedToWrite);
        }
    }];
}

@end
