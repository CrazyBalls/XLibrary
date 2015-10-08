//
//  XGroupTableModel.m
//  XFrameworkExample
//
//  Created by XJY on 15-8-10.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import "XGroupTableModel.h"

@implementation XGroupTableModel

- (instancetype)init {
    return [self initWithLevel:0
               nextLevelModels:[[NSArray alloc] init]
                 cellClassName:@""];
}

- (instancetype)initWithLevel:(NSInteger)level
    nextLevelModels:(NSArray *)nextLevelModels
      cellClassName:(NSString *)cellClassName {
    self = [super init];
    if (self) {
        _level = level;
        _nextIsShowing = NO;
        _nextLevelModels = nextLevelModels;
        _cellClassName = cellClassName;
        _allowSelect = NO;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:[NSNumber numberWithInteger:_level] forKey:@"level"];
    [encoder encodeObject:[NSNumber numberWithBool:_nextIsShowing] forKey:@"nextIsShowing"];
    [encoder encodeObject:_nextLevelModels forKey:@"nextLevelModels"];
    [encoder encodeObject:_cellClassName forKey:@"cellClassName"];
    [encoder encodeObject:[NSNumber numberWithBool:_allowSelect] forKey:@"allowSelect"];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        _level = [[decoder decodeObjectForKey:@"level"] integerValue];
        _nextIsShowing = [[decoder decodeObjectForKey:@"nextIsShowing"] boolValue];
        _nextLevelModels = [decoder decodeObjectForKey:@"nextLevelModels"];
        _cellClassName = [decoder decodeObjectForKey:@"cellClassName"];
        _allowSelect = [[decoder decodeObjectForKey:@"allowSelect"] boolValue];
    }
    return self;
}

@end
