//
//  XImageTool.h
//  XFramework
//
//  Created by XJY on 15-7-26.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface XImageTool : NSObject

/**
 从工程目录加载图片,传入图片名,适用于大图,无缓存
 */
+ (UIImage *)initImageWithContentsOfName:(NSString *)imageName;

/**
 从工程目录加载图片,传入图片名,适用于不大并且不常用的图片,无缓存
 */
+ (UIImage *)imageWithContentsOfName:(NSString *)imageName;

/**
 从工程目录加载图片,传入图片名和图片类型,适用于大图,无缓存
 */
+ (UIImage *)initImageWithContentsOfName:(NSString *)imageName type:(NSString *)type;

/**
 从工程目录加载图片,传入图片名和图片类型,适用于不大并且不常用的图片,无缓存
 */
+ (UIImage *)imageWithContentsOfName:(NSString *)imageName type:(NSString *)type;

/**
 从工程目录加载图片,适用于不大并且经常使用,特别是频繁访问的图片,缓存到内存
 */
+ (UIImage *)imageNamed:(NSString *)imageName;

/**
 将指定颜色制作成图片
 */
+ (UIImage *)imageWithColor:(UIColor *)color;

/**
 将图片进行旋转处理
 */
+ (UIImage *)fixOrientation:(UIImage *)aImage;

/**
 将图片修改为指定大小(size)
 */
+ (NSData *)changeImageSize:(UIImage*)sourceImage scaledToSize:(CGSize)newSize;

/**
 将图片压缩到指定大小(data)
 */
+ (NSData *)compressWithSourceImage:(UIImage *)sourceImage targetImageLength:(CGFloat)targetImageLength;

/**
 将UIImage转化为NSData
 */
+ (NSData *)dataWithImage:(UIImage *)image ;

@end
