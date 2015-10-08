//
//  TestModel.h
//  XExample
//
//  Created by XJY on 15/9/28.
//  Copyright © 2015年 XJY. All rights reserved.
//

#import <XFramework/XFramework.h>

@interface TestModel : XGroupTableModel

@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) UIColor *bgColor;

@end
