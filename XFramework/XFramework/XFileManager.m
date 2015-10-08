//
//  XFileManager.m
//  XFramework
//
//  Created by XJY on 15-7-26.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import "XFileManager.h"
#import "XTool.h"

@implementation XFileManager

+ (NSString *)appendingPathComponent:(NSString *)componentStr sourcePath:(NSString *)sourcePath {
    NSString *newPath = [sourcePath stringByAppendingPathComponent:componentStr];
    return newPath;
}

+ (NSString *)getDocumentDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [paths objectAtIndex:0];
    return documentPath;
}

+ (BOOL)isDirectoryExist:(NSString *)directoryPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = YES;
    BOOL result = [fileManager fileExistsAtPath:directoryPath isDirectory:&isDir];
    if (result == YES) {
        if (isDir == NO) {
            result = NO;
        }
    }
    return result;
}

+ (BOOL)isFileExist:(NSString *)filePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = [fileManager fileExistsAtPath:filePath];
    return result;
}

+ (BOOL)createDirectory:(NSString *)directoryPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = [fileManager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    return result;
}

+ (BOOL)createFile:(NSString *)fileName directoryPath:(NSString *)directoryPath contents:(NSData *)contents allowMulti:(BOOL)allowMulti {
    if ([XTool isStringEmpty:fileName] == YES) {
        return NO;
    }
    if ([XTool isStringEmpty:directoryPath] == YES) {
        return NO;
    }
    
    BOOL fileResult = NO;
    BOOL directoryResult = NO;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectoryExist = [self isDirectoryExist:directoryPath];
    if (isDirectoryExist == NO) {
        directoryResult = [self createDirectory:directoryPath];
    } else {
        directoryResult = YES;
    }
    if (directoryResult == YES) {
        NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
        BOOL isFileExist = [self isFileExist:filePath];
        if (isFileExist == YES) {
            if (allowMulti == YES) {
                NSString *componentsStr = @".";
                NSString *appendingStr = [XTool getCurrentTime:@"yyyyMMddHHmmss"];
                NSString *newFileName = @"";
                NSRange range = [fileName rangeOfString:componentsStr];
                if (range.location == NSNotFound) {
                    newFileName = [fileName stringByAppendingString:appendingStr];
                } else {
                    NSArray *fileNameArr = [fileName componentsSeparatedByString:componentsStr];
                    NSString *fileNameWithoudType = [fileNameArr firstObject];
                    NSString *fileType = [fileNameArr lastObject];
                    fileNameWithoudType = [fileNameWithoudType stringByAppendingString:appendingStr];
                    newFileName = [fileNameWithoudType stringByAppendingString:componentsStr];
                    newFileName = [newFileName stringByAppendingString:fileType];
                }
                filePath = [directoryPath stringByAppendingPathComponent:newFileName];
            } else {
                NSError *error = nil;
                [fileManager removeItemAtPath:filePath error:&error];
                if (error != nil) {
                    return NO;
                }
            }
        }
        fileResult = [fileManager createFileAtPath:filePath contents:contents attributes:nil];
    } else {
        fileResult = NO;
    }
    return fileResult;
}

+ (NSData *)readFile:(NSString *)filePath {
    NSData *data = nil;
    BOOL isFileExist = [self isFileExist:filePath];
    if (isFileExist == YES) {
        data = [NSData dataWithContentsOfFile:filePath];
    }
    return data;
}

+ (BOOL)removeFile:(NSString *)filePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    BOOL result = [fileManager removeItemAtPath:filePath error:&error];
    if (error != nil) {
        result = NO;
    }
    return result;
}

+ (NSString *)getFileNameWithSufixForPath:(NSString *)filePath {
    NSString *fileNameWithSufix = @"";
    if ([XTool isStringEmpty:filePath] == NO) {
        if ([filePath rangeOfString:@"/"].location != NSNotFound) {
            NSArray *filePathComponentsArr = [filePath componentsSeparatedByString:@"/"];
            fileNameWithSufix = [filePathComponentsArr lastObject];
        }
    }
    return fileNameWithSufix;
}

+ (NSString *)getFileNameWithoutSufixForPath:(NSString *)filePath {
    NSString *fileNameWithSufix = [self getFileNameWithSufixForPath:filePath];
    NSString *fileNameWithoutSufix = [self getFileNameWithoutSufixForName:fileNameWithSufix];
    return fileNameWithoutSufix;
}

+ (NSString *)getFileNameWithoutSufixForName:(NSString *)fileNameWithSufix {
    NSString *fileNameWithoutSufix = @"";
    if ([XTool isStringEmpty:fileNameWithSufix] == NO) {
        if ([fileNameWithSufix rangeOfString:@"."].location != NSNotFound) {
            NSArray *fileNameArr = [fileNameWithSufix componentsSeparatedByString:@"."];
            fileNameWithoutSufix = [fileNameArr firstObject];
        } else {
            fileNameWithoutSufix = fileNameWithSufix;
        }
    }
    return fileNameWithoutSufix;
}

+ (NSString *)getSufixForPath:(NSString *)filePath {
    NSString *fileNameWithSufix = [self getFileNameWithSufixForPath:filePath];
    NSString *fileNameSufix = [self getSufixForName:fileNameWithSufix];
    return fileNameSufix;
}

+ (NSString *)getSufixForName:(NSString *)fileNameWithSufix {
    NSString *fileNameSufix = @"";
    if ([XTool isStringEmpty:fileNameWithSufix] == NO) {
        if ([fileNameWithSufix rangeOfString:@"."].location != NSNotFound) {
            NSArray *fileNameArr = [fileNameWithSufix componentsSeparatedByString:@"."];
            fileNameSufix = [fileNameArr lastObject];
        }
    }
    return fileNameSufix;
}

+ (NSArray *)getAllFiles:(NSString *)directoryPath {
    if ([self isDirectoryExist:directoryPath] == NO) {
        return nil;
    } else {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error = nil;
        NSArray *allFiles = [fileManager contentsOfDirectoryAtPath:directoryPath error:&error];
        if (error != nil) {
            return nil;
        } else {
            return allFiles;
        }
    }
}

+ (NSString *)getBundleResourcePathWithName:(NSString *)resourceName type:(NSString *)type {
    NSString *localResourcePath = @"";
    if ([XTool isStringEmpty:resourceName] == YES) {
        localResourcePath = @"";
    } else {
        localResourcePath = [[NSBundle mainBundle] pathForResource:resourceName ofType:type];
    }
    return localResourcePath;
}

+ (BOOL)archive:(id)rootObject keyedArchiveName:(NSString *)keyedArchiveName directoryPath:(NSString *)directoryPath {
    if ([self isDirectoryExist:directoryPath] == NO) {
        [self createDirectory:directoryPath];
    }
    NSString *keyedArchivePath = [directoryPath stringByAppendingPathComponent:keyedArchiveName];
    return [NSKeyedArchiver archiveRootObject:rootObject toFile:keyedArchivePath];
}

+ (id)unarchive:(NSString *)filePath {
    return [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
}

@end
