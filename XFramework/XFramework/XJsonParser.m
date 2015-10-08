//
//  XJsonParser.m
//  XFramework
//
//  Created by XJY on 15-7-26.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import "XJsonParser.h"
#import "XTool.h"

@implementation XJsonParser

+ (void)parseJsonWithData:(NSMutableData *)jsonData completed:(JsonParserCompletionBlock)completedBlock {
    NSError *error;
    id parseResult = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&error];
    if (completedBlock) {
        completedBlock(parseResult, error);
    }
}

+ (void)parseJsonWithString:(NSString *)jsonStr completed:(JsonParserCompletionBlock)completedBlock {
    [self parseJsonWithString:jsonStr encoding:NSUTF8StringEncoding completed:completedBlock];
}

+ (void)parseJsonWithString:(NSString *)jsonStr encoding:(NSStringEncoding)encoding completed:(JsonParserCompletionBlock)completedBlock {
    if ([XTool isStringEmpty:jsonStr] == NO) {
        NSMutableData *jsonData = [NSMutableData dataWithData:[jsonStr dataUsingEncoding:encoding]];
        [self parseJsonWithData:jsonData completed:completedBlock];
    } else {
        if (completedBlock) {
           completedBlock(nil, nil);
        }
    }
}

@end
