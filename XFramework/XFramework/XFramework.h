//
//  XFramework.h
//  XFramework
//
//  Created by XJY on 15/9/19.
//  Copyright © 2015年 XJY. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for XFramework.
FOUNDATION_EXPORT double XFrameworkVersionNumber;

//! Project version string for XFramework.
FOUNDATION_EXPORT const unsigned char XFrameworkVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <XFramework/PublicHeader.h>


#ifdef __OBJC__
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

//define this constant if you want to use Masonry without the 'mas_' prefix
#define MAS_SHORTHAND

//define this constant if you want to enable auto-boxing for default syntax
#define MAS_SHORTHAND_GLOBALS

#import "Masonry.h"
#endif

#import "AFNetworking.h"
#import "UIKit+AFNetworking.h"
#import "UIImage+AFNetworking.h"
#import "MJRefresh.h"
#import "MBProgressHUD.h"
#import "Reachability.h"
#import "KeyboardManager.h"
#import "Base64.h"
#import "libPhoneNumber.h"

#import "MKAnnotationView+WebCache.h"
#import "NSData+ImageContentType.h"
#import "SDImageCache.h"
#import "SDWebImageCompat.h"
#import "SDWebImageDecoder.h"
#import "SDWebImageDownloader.h"
#import "SDWebImageDownloaderOperation.h"
#import "SDWebImageManager.h"
#import "SDWebImageOperation.h"
#import "SDWebImagePrefetcher.h"
#import "UIButton+WebCache.h"
#import "UIImage+GIF.h"
#import "UIImage+MultiFormat.h"
#import "UIImage+WebP.h"
#import "UIImageView+HighlightedWebCache.h"
#import "UIImageView+WebCache.h"
#import "UIView+WebCacheOperation.h"

#import "XTool.h"
#import "XFileManager.h"
#import "XCookieManager.h"
#import "XFoundation.h"
#import "XIOSVersion.h"
#import "XTimer.h"
#import "XImageTool.h"
#import "XJsonParser.h"
#import "XHttpRequest.h"
#import "XHttpUploadFile.h"
#import "XPhone.h"
#import "XReachabilityManager.h"
#import "XAnimation.h"
#import "XPhoto.h"

#import "XKeyBoardManager.h"
#import "XRefresh.h"
#import "XAlert.h"
#import "XGroupTable.h"
#import "XGroupTableCell.h"
#import "XGroupTableModel.h"
#import "XGallery.h"
#import "XBottomBar.h"
#import "XTabBar.h"
#import "XTitleView.h"
#import "XProgress.h"
#import "XAlertContainer.h"

#import "XPageViewController.h"

#import "XScrollView.h"
#import "XTableView.h"
#import "XImageView.h"
#import "XTextField.h"
#import "XTextView.h"
#import "XSearchBar.h"
#import "XLabel.h"
#import "XControl.h"
