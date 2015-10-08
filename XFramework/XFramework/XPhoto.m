//
//  XPhoto.m
//  XFramework
//
//  Created by XJY on 15/9/23.
//  Copyright © 2015年 XJY. All rights reserved.
//

#import "XPhoto.h"

@interface XPhoto () <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    UIViewController *oprationViewController;
    
    NSString *cancelTitle;
    NSString *cameraTitle;
    NSString *localAlbumTitle;
    
    XPhotoSelectedCompleteBlock photoSelectedCompleteBlock;
    XPhotoSelectedFailureBlock  photoSelectedFailureBlock;
    
    XPhoto *saveInstance;
}

@end

@implementation XPhoto

- (void)selectPhotoInViewController:(UIViewController *)viewController
                              title:(NSString *)title
                  cancelButtonTitle:(NSString *)cancelButtonTitle
                  cameraButtonTitle:(NSString *)cameraButtonTitle
              localAlbumButtonTitle:(NSString *)localAlbumButtonTitle
         photoCompleteSelectedBlock:(XPhotoSelectedCompleteBlock)selectedCompleteBlock
          photoFailureSelectedBlock:(XPhotoSelectedFailureBlock)selectedFailureBlock {
    
    saveInstance = self;
    
    photoSelectedCompleteBlock = selectedCompleteBlock;
    photoSelectedFailureBlock = selectedFailureBlock;
    
    oprationViewController = viewController;
    cancelTitle = cancelButtonTitle;
    cameraTitle = cameraButtonTitle;
    localAlbumTitle = localAlbumButtonTitle;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title
                                                             delegate:self
                                                    cancelButtonTitle:cancelButtonTitle
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:cameraButtonTitle, localAlbumButtonTitle, nil];
    [actionSheet setActionSheetStyle:UIActionSheetStyleDefault];
    [actionSheet showInView:viewController.view];
}

- (void)takeCameraPhoto {
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable:sourceType] == NO) {
        [self getLocalPhoto];
    } else {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        [picker setDelegate:self];
        [picker setAllowsEditing:NO];
        [picker setSourceType:sourceType];
        [oprationViewController presentViewController:picker animated:YES completion:^{
            
        }];
    }
}

- (void)getLocalPhoto {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    [picker setDelegate:self];
    [picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [picker setAllowsEditing:NO];
    [oprationViewController presentViewController:picker animated:YES completion:^{
        
    }];
}

#pragma mark UIActionSheetDelegate Method

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:cancelTitle] == YES) {
        
    } else if ([buttonTitle isEqualToString:cameraTitle] == YES) {
        [self takeCameraPhoto];
    } else if ([buttonTitle isEqualToString:localAlbumTitle] == YES) {
        [self getLocalPhoto];
    }
    return;
}

#pragma mark UIImagePickerControllerDelegate Method

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
        if ([type isEqualToString:@"public.image"]) {
            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
            
            if (photoSelectedCompleteBlock) {
                photoSelectedCompleteBlock(self, image, picker.sourceType);
            }
            
            if(_delegate != nil && [_delegate respondsToSelector:@selector(photoCompleteSelected:image:sourceType:)]) {
                [_delegate photoCompleteSelected:self image:image sourceType:picker.sourceType];
            }
            
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        
        if (photoSelectedFailureBlock) {
            photoSelectedFailureBlock(self);
        }
        
        if(_delegate != nil && [_delegate respondsToSelector:@selector(photoFailureSelected:)]) {
            [_delegate photoFailureSelected:self];
        }
        
    }];
}

@end
