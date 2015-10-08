//
//  XPhoto.h
//  XFramework
//
//  Created by XJY on 15/9/23.
//  Copyright © 2015年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class XPhoto;

@protocol XPhotoDelegate <NSObject>

@optional
- (void)photoCompleteSelected:(XPhoto *)x_Photo image:(UIImage *)image sourceType:(UIImagePickerControllerSourceType)sourceType;
- (void)photoFailureSelected:(XPhoto *)x_Photo;

@end

@interface XPhoto : NSObject

typedef void (^XPhotoSelectedCompleteBlock)(XPhoto *x_Photo, UIImage *image, UIImagePickerControllerSourceType sourceType);
typedef void (^XPhotoSelectedFailureBlock)(XPhoto *x_Photo);

@property (nonatomic, assign) id <XPhotoDelegate> delegate;

- (void)selectPhotoInViewController:(UIViewController *)viewController
                              title:(NSString *)title
                  cancelButtonTitle:(NSString *)cancelButtonTitle
                  cameraButtonTitle:(NSString *)cameraButtonTitle
              localAlbumButtonTitle:(NSString *)localAlbumButtonTitle
         photoCompleteSelectedBlock:(XPhotoSelectedCompleteBlock)selectedCompleteBlock
          photoFailureSelectedBlock:(XPhotoSelectedFailureBlock)selectedFailureBlock;

@end

