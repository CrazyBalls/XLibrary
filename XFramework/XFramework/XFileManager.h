//
//  XFileManager.h
//  XFramework
//
//  Created by XJY on 15-7-26.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XFileManager : NSObject

/**
 将字符串追加到地址末尾,自动补上‘/’
 */
+ (NSString *)appendingPathComponent:(NSString *)componentStr sourcePath:(NSString *)sourcePath;

/**
 获取沙盒中的documents路径
 */
+ (NSString *)getDocumentDirectory;

/**
 判断文件夹是否存在
 */
+ (BOOL)isDirectoryExist:(NSString *)directoryPath;

/**
 判断文件是否存在
 */
+ (BOOL)isFileExist:(NSString *)filePath;

/**
 创建文件夹
 */
+ (BOOL)createDirectory:(NSString *)directoryPath;

/**
 创建文件,allowMulti表示是否允许重名.YES则在文件名后补上当前时间保存;NO则覆盖同名文件,只保留最新文件.
 */
+ (BOOL)createFile:(NSString *)fileName directoryPath:(NSString *)directoryPath contents:(NSData *)contents allowMulti:(BOOL)allowMulti;

/**
 读取文件
 */
+ (NSData *)readFile:(NSString *)filePath;

/**
 删除文件
 */
+ (BOOL)removeFile:(NSString *)filePath;

/**
 从文件路径获取带后缀的文件名,如果传入的参数不是合法路径或者为空,则返回空字符串.
 */
+ (NSString *)getFileNameWithSufixForPath:(NSString *)filePath;

/**
 从文件路径获取不带后缀的文件名,如果传入的参数不是合法路径或者为空,则返回空字符串.
 */
+ (NSString *)getFileNameWithoutSufixForPath:(NSString *)filePath;

/**
 从文件名获取不带后缀的文件名,如果传入的参数为空,则返回空字符串.
 */
+ (NSString *)getFileNameWithoutSufixForName:(NSString *)fileNameWithSufix;

/**
 从文件路径获取文件名后缀,如果传入的参数不是合法路径或者为空,则返回空字符串.
 */
+ (NSString *)getSufixForPath:(NSString *)filePath;

/**
 从文件名获取后缀,如果传入的参数为空或者无点符号,则返回空字符串.
 */
+ (NSString *)getSufixForName:(NSString *)fileNameWithSufix;

/**
 获取指定文件夹下的所有文件列表
 */
+ (NSArray *)getAllFiles:(NSString *)directoryPath;

/**
 获取工程中的资源文件路径
 */
+ (NSString *)getBundleResourcePathWithName:(NSString *)resourceName type:(NSString *)type;

/**
 归档保存实例对象
 */
+ (BOOL)archive:(id)rootObject keyedArchiveName:(NSString *)keyedArchiveName directoryPath:(NSString *)directoryPath;

/**
 从归档文件读取实例对象
 */
+ (id)unarchive:(NSString *)filePath;

@end
