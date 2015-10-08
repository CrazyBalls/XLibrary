//
//  XFoundation.m
//  XFramework
//
//  Created by XJY on 15-7-26.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import "XFoundation.h"

@implementation XFoundation

@end

@implementation NSArray (XArray)

- (id)x_objectAtIndex:(NSInteger)index {
#ifdef DEBUG
    return [self objectAtIndex:index];
#else
    if (index >= 0 && index < self.count) {
        return [self objectAtIndex:index];
    } else {
        return nil;
    }
#endif
}

@end

@implementation NSMutableArray (XMutableArray)

- (void)x_addObject:(id)anObject {
#ifdef DEBUG
    [self addObject:anObject];
#else
    if (anObject != nil) {
        [self addObject:anObject];
    }
#endif
}

- (void)x_removeObjectAtIndex:(NSInteger)index {
#ifdef DEBUG
    [self removeObjectAtIndex:index];
#else
    if (self.count > 0 && index >= 0 && index < self.count) {
        [self removeObjectAtIndex:index];
    }
#endif
}

- (void)x_insertObject:(id)anObject atIndex:(NSInteger)index {
#ifdef DEBUG
    [self insertObject:anObject atIndex:index];
#else
    if (anObject != nil) {
        if (self.count == 0) {
            if (index == 0) {
                [self insertObject:anObject atIndex:index];
            }
        } else if (self.count > 0) {
            if (index >= 0 && index <= self.count) {
                [self insertObject:anObject atIndex:index];
            }
        }
    }
#endif
}

- (void)x_replaceObjectAtIndex:(NSInteger)index withObject:(id)anObject {
#ifdef DEBUG
    [self replaceObjectAtIndex:index withObject:anObject];
#else
    if (anObject != nil) {
        if (self.count > 0 && index >= 0 && index < self.count) {
            [self replaceObjectAtIndex:index withObject:anObject];
        }
    }
#endif
}

@end

@implementation NSMutableDictionary (XDictionary)

- (void)x_setObject:(id)anObject forKey:(id<NSCopying>)aKey {
#ifdef DEBUG
    [self setObject:anObject forKey:aKey];
#else
    if (anObject != nil) {
        [self setObject:anObject forKey:aKey];
    }
#endif
}

@end