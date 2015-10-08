//
//  XJsonParser.h
//  XFramework
//
//  Created by XJY on 15-7-26.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XJsonParser : NSObject

typedef void(^JsonParserCompletionBlock)(id parseResult, NSError *error);

/**
 解析NSData形式的json
 */
+ (void)parseJsonWithData:(NSMutableData *)jsonData completed:(JsonParserCompletionBlock)completedBlock;

/**
 解析NSString形式的json
 */
+ (void)parseJsonWithString:(NSString *)jsonStr encoding:(NSStringEncoding)encoding completed:(JsonParserCompletionBlock)completedBlock;

/**
 解析NSString形式的json, UTF-8编码
 */
+ (void)parseJsonWithString:(NSString *)jsonStr completed:(JsonParserCompletionBlock)completedBlock;

@end
