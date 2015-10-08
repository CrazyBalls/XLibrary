//
//  XFoundation.h
//  XFramework
//
//  Created by XJY on 15-7-26.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XFoundation : NSObject

@end

@interface NSArray (XArray)

- (id)x_objectAtIndex:(NSInteger)index;

@end

@interface NSMutableArray (XMutableArray)

- (void)x_addObject:(id)anObject;
- (void)x_removeObjectAtIndex:(NSInteger)index;
- (void)x_insertObject:(id)anObject atIndex:(NSInteger)index;
- (void)x_replaceObjectAtIndex:(NSInteger)index withObject:(id)anObject;

@end

@interface NSMutableDictionary (XDictionary)

- (void)x_setObject:(id)anObject forKey:(id<NSCopying>)aKey;

@end