//
//  XGroupTable.m
//  XFrameworkExample
//
//  Created by XJY on 15-8-10.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import "XGroupTable.h"
#import "XGroupTableModel.h"
#import "XGroupTableCell.h"
#import "XTool.h"
#import "XFoundation.h"

@interface XGroupTable() <UITableViewDataSource, UITableViewDelegate> {
    
    
    NSMutableDictionary *   groupsDictionary;
    NSMutableDictionary *   groupTableCellClassesNameDic;
    
    GetNextLevelDataBlock   getNextLevelDataBlock;
    
    XGroupTableStyle        groupTableStyle;
}

@end

@implementation XGroupTable

#pragma mark ---------- Public ----------

- (instancetype)initWithGroups:(NSArray *)groups style:(XGroupTableStyle)style {
    self = [super init];
    if (self) {
        [self initialize:style];
        [self loadGroups:groups];
        [self addGroupsTableView];
    }
    return self;
}

- (instancetype)initWithGroups:(NSArray *)groups {
    return [self initWithGroups:groups style:XGroupTableStyleSingle];
}

- (instancetype)initWithStyle:(XGroupTableStyle)style {
    return [self initWithGroups:nil style:style];
}

- (void)showScrollIndicator:(BOOL)show {
    if (_tableView == nil) {
        return;
    }
    
    [_tableView setShowsHorizontalScrollIndicator:show];
    [_tableView setShowsVerticalScrollIndicator:show];
}

#pragma mark reload data

- (void)reloadData:(NSArray *)groups {
    [self loadGroups:groups];
    [self reloadData];
}

- (void)reloadData {
    if (_tableView == nil) {
        return;
    }
    
    [self registerCellClass];
    [_tableView reloadData];
}

#pragma mark get data

- (void)getNextLevelData:(GetNextLevelDataBlock)block {
    getNextLevelDataBlock = block;
}

#pragma mark select

- (void)didSelectRowForModel:(id)model {
    if (model == nil) {
        return;
    }
    
    NSIndexPath *indexPath = [self indexPathForModel:model];
    if (indexPath == nil) {
        return;
    }
    
    [self didSelectRowAtIndexPath:indexPath];
}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath == nil) {
        return;
    }
    if ([XTool isDictionaryEmpty:groupsDictionary] == YES) {
        return;
    }
    
    XGroupTableCell *cell = (XGroupTableCell *)[_tableView cellForRowAtIndexPath:indexPath];
    if (cell.currentGroupTableModel == nil) {
        return;
    }
    
    if (cell.currentGroupTableModel.nextIsShowing == NO) {//下一级未展开, 点击后展开
        if (groupTableStyle == XGroupTableStyleSingle) {
            [self closeThisGroupOtherSameLevelOrLowerShowingRows:_tableView withIndexPath:indexPath withModel:cell.currentGroupTableModel];
        }
        [cell.currentGroupTableModel setNextIsShowing:YES];
        if ([XTool isArrayEmpty:cell.currentGroupTableModel.nextLevelModels] == NO) {//下一级有数据
            [self openGroupWithTableView:_tableView withIndexPath:indexPath withModel:cell.currentGroupTableModel];
        } else {//下一级无数据
            NSArray *nextLevelModels = nil;
            if (getNextLevelDataBlock) {
                nextLevelModels = getNextLevelDataBlock(cell.currentGroupTableModel);
            }
            if ([XTool isArrayEmpty:nextLevelModels] == NO) {//搜索到下一级的数据
                [cell.currentGroupTableModel setNextLevelModels:nextLevelModels];
                [self openGroupWithTableView:_tableView withIndexPath:indexPath withModel:cell.currentGroupTableModel];
            } else {//下一级确实没有数据
                
            }
        }
    } else {//下一级已展开,点击后收起, 从当前点击的行往下查找, 当level比当前行高(即等级更低), 就删除, 一旦遇到等级一样或者更高时, 就退出循环。
        [cell.currentGroupTableModel setNextIsShowing:NO];
        [self closeGroupWithTableView:_tableView withIndexPath:indexPath withModel:cell.currentGroupTableModel];
    }
}

#pragma mark insert

- (void)insertRoot:(id)newRootModel atIndex:(NSInteger)atIndex {
    if (newRootModel == nil) {
        return;
    }
    
    if (groupsDictionary == nil) {
        return;
    }
    
    if (atIndex < 0 || atIndex == NSNotFound || atIndex > groupsDictionary.count) {
        return;
    }
    if (atIndex < groupsDictionary.count) {
        for (NSInteger section = groupsDictionary.count - 1; section >= atIndex;  section --) {
            NSNumber *oldSectionNumber = [NSNumber numberWithInteger:section];
            NSNumber *newSectionNumber = [NSNumber numberWithInteger:section+1];
            NSArray *groupModelForRowArray = [groupsDictionary objectForKey:oldSectionNumber];
            [groupsDictionary x_setObject:groupModelForRowArray forKey:newSectionNumber];
        }
    }

    [groupsDictionary x_setObject:@[newRootModel] forKey:[NSNumber numberWithInteger:atIndex]];
    
    [self addCellClassesName:((XGroupTableModel *)newRootModel).cellClassName];
    [self registerCellClass];
    
    if (_animated == YES) {
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:atIndex];
        [_tableView beginUpdates];
        [_tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
        [_tableView endUpdates];
    } else {
        [_tableView reloadData];
    }
}

- (void)insertRoot:(id)newRootModel {
    if (newRootModel == nil) {
        return;
    }
    
    if (groupsDictionary == nil) {
        return;
    }
    
    [self insertRoot:newRootModel atIndex:groupsDictionary.count];
}

- (void)insertRowForModel:(id)newModel rootModel:(id)rootModel fatherModel:(id)fatherModel atIndex:(NSInteger)atIndex {
    if (newModel != nil && fatherModel == nil && rootModel == nil) {
        [self insertRoot:newModel atIndex:atIndex];
        return;
    }
    
    if (newModel == nil || rootModel == nil || fatherModel == nil) {
        return;
    }
    
    if (atIndex < 0 || atIndex == NSNotFound) {
        return;
    }
    
    if ([XTool isDictionaryEmpty:groupsDictionary] == YES) {
        return;
    }
    
    NSInteger rootIndex = [self indexForRoot:rootModel];
    if (rootIndex == NSNotFound) {
        return;
    }
    
    XGroupTableModel *fatherGroupModel = (XGroupTableModel *)fatherModel;
    
    if (atIndex > fatherGroupModel.nextLevelModels.count) {
        return;
    }
    
    NSMutableArray *fatherModelNextLevelModels = [[NSMutableArray alloc] initWithArray:fatherGroupModel.nextLevelModels];
    [fatherModelNextLevelModels x_insertObject:newModel atIndex:atIndex];
    [fatherGroupModel setNextLevelModels:fatherModelNextLevelModels];
    
    if (fatherGroupModel.nextIsShowing == NO) {
        return;
    }
    
    XGroupTableModel *rootGroupModel = (XGroupTableModel *)rootModel;
    if (rootGroupModel.nextIsShowing == NO) {
        return;
    }

    NSNumber *sectionNumber = [NSNumber numberWithInteger:rootIndex];
    NSArray *groupModelForRowArray = [groupsDictionary objectForKey:sectionNumber];
    
    NSInteger fatherIndex = [groupModelForRowArray indexOfObject:fatherGroupModel];
    if (fatherIndex == NSNotFound) {
        return;
    }
    
    NSMutableArray *groupModelForRowMutableArray = [[NSMutableArray alloc] initWithArray:groupModelForRowArray];
    
    XGroupTableModel *newGroupModel = (XGroupTableModel *)newModel;
    
    if (atIndex == 0) {
        NSInteger insertRow = fatherIndex + 1;
        [groupModelForRowMutableArray x_insertObject:newGroupModel atIndex:insertRow];
        [groupsDictionary x_setObject:groupModelForRowMutableArray forKey:sectionNumber];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:insertRow inSection:[sectionNumber integerValue]];
        
        [self addCellClassesName:newGroupModel.cellClassName];
        [self registerCellClass];
        
        if (_animated == YES) {
            [_tableView beginUpdates];
            [_tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [_tableView endUpdates];
        } else {
            [_tableView reloadData];
        }
        
        return;
    }
    
    NSInteger brothersCount = 0;
    for (NSInteger i = fatherIndex + 1; i < groupModelForRowMutableArray.count; i++) {
        XGroupTableModel *model = [groupModelForRowMutableArray x_objectAtIndex:i];
        if (model.level <= fatherGroupModel.level) {
            return;
        }
        if (model.level == newGroupModel.level) {
            brothersCount++;
            if (atIndex == brothersCount) {
                
                NSInteger insertRow = NSNotFound;
                for (NSInteger j = i + 1; j < groupModelForRowMutableArray.count; j ++) {
                    XGroupTableModel *subModel = [groupModelForRowMutableArray x_objectAtIndex:j];
                    if (subModel.level <= newGroupModel.level) {
                        insertRow = j;
                        break;
                    }
                }
                if (insertRow == NSNotFound) {
                    insertRow = groupModelForRowMutableArray.count;
                }
                
                if (insertRow < 0 || insertRow > groupModelForRowMutableArray.count) {
                    return;
                }
                
                [groupModelForRowMutableArray x_insertObject:newGroupModel atIndex:insertRow];
                [groupsDictionary x_setObject:groupModelForRowMutableArray forKey:sectionNumber];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:insertRow inSection:[sectionNumber integerValue]];
                
                [self addCellClassesName:newGroupModel.cellClassName];
                [self registerCellClass];
                
                if (_animated == YES) {
                    [_tableView beginUpdates];
                    [_tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    [_tableView endUpdates];
                } else {
                    [_tableView reloadData];
                }
                
                return;
            }
        }
    }
}

- (void)insertRowForModel:(id)newModel rootModel:(id)rootModel fatherModel:(id)fatherModel {
    if (newModel != nil && fatherModel == nil && rootModel == nil) {
        [self insertRoot:newModel];
        return;
    }
    
    if (newModel == nil || rootModel == nil || fatherModel == nil) {
        return;
    }
    
    XGroupTableModel *fatherGroupModel = (XGroupTableModel *)fatherModel;
    NSInteger insertIndex = 0;
    if ([XTool isArrayEmpty:fatherGroupModel.nextLevelModels] == NO) {
        insertIndex = fatherGroupModel.nextLevelModels.count;
    }
    
    [self insertRowForModel:newModel rootModel:rootModel fatherModel:fatherModel atIndex:insertIndex];
}

#pragma mark remove

- (void)removeRootAtIndex:(NSInteger)atIndex {
    if (atIndex == NSNotFound || atIndex < 0) {
        return;
    }
    
    if ([XTool isDictionaryEmpty:groupsDictionary] == YES) {
        return;
    }
    
    if (atIndex >= groupsDictionary.count) {
        return;
    }
    
    if (atIndex == groupsDictionary.count - 1) {
        [groupsDictionary removeObjectForKey:[NSNumber numberWithInteger:atIndex]];
    } else {
        for (NSInteger section = atIndex+1; section < groupsDictionary.count; section ++) {
            NSNumber *oldSectionNumber = [NSNumber numberWithInteger:section];
            NSNumber *newSectionNumber = [NSNumber numberWithInteger:section-1];
            NSArray *groupModelForRowArray = [groupsDictionary objectForKey:oldSectionNumber];
            [groupsDictionary x_setObject:groupModelForRowArray forKey:newSectionNumber];
            
            if (section == groupsDictionary.count - 1) {
                [groupsDictionary removeObjectForKey:oldSectionNumber];
            }
        }
    }
    
    if (_animated == YES) {
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:atIndex];
        [_tableView beginUpdates];
        [_tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
        [_tableView endUpdates];
    } else {
        [_tableView reloadData];
    }
}

- (void)removeRoot:(id)rootModel {
    if (rootModel == nil) {
        return;
    }
    
    if ([XTool isDictionaryEmpty:groupsDictionary] == YES) {
        return;
    }

    NSInteger waitRemoveSection = [self indexForRoot:rootModel];
    
    if (waitRemoveSection == NSNotFound || waitRemoveSection < 0) {
        return;
    }
    
    [self removeRootAtIndex:waitRemoveSection];
}

- (void)removeFirstRoot {
    [self removeRootAtIndex:0];
}

- (void)removeLastRoot {
    if ([XTool isDictionaryEmpty:groupsDictionary] == YES) {
        return;
    }
    [self removeRootAtIndex:groupsDictionary.count - 1];
}

- (void)removeRowAtIndex:(NSInteger)atIndex rootModel:(id)rootModel fatherModel:(id)fatherModel {
    if (atIndex == NSNotFound || atIndex < 0) {
        return;
    }
    
    if (rootModel == nil && fatherModel == nil) {
        [self removeRootAtIndex:atIndex];
        return;
    }
    
    if (rootModel == nil || fatherModel == nil) {
        return;
    }
    
    if ([XTool isDictionaryEmpty:groupsDictionary] == YES) {
        return;
    }
    
    XGroupTableModel *fatherGroupModel = (XGroupTableModel *)fatherModel;
    
    if (atIndex >= fatherGroupModel.nextLevelModels.count) {
        return;
    }
    
    id removeModel = [fatherGroupModel.nextLevelModels x_objectAtIndex:atIndex];
    [self removeRowForModel:removeModel rootModel:rootModel fatherModel:fatherModel];
}

- (void)removeRowForModel:(id)removeModel rootModel:(id)rootModel fatherModel:(id)fatherModel {
    if (removeModel != nil && rootModel == nil && fatherModel == nil) {
        [self removeRoot:removeModel];
        return;
    }
    
    if (removeModel == nil || rootModel == nil || fatherModel == nil) {
        return;
    }
    
    if ([XTool isDictionaryEmpty:groupsDictionary] == YES) {
        return;
    }
    
    XGroupTableModel *fatherGroupModel = (XGroupTableModel *)fatherModel;
    
    if ([fatherGroupModel.nextLevelModels containsObject:removeModel] == YES) {
        NSMutableArray *fatherModelNextLevelModels = [[NSMutableArray alloc] initWithArray:fatherGroupModel.nextLevelModels];
        [fatherModelNextLevelModels removeObject:removeModel];
        [fatherGroupModel setNextLevelModels:fatherModelNextLevelModels];
    }
    
    if (fatherGroupModel.nextIsShowing == NO) {
        return;
    }
    
    XGroupTableModel *rootGroupModel = (XGroupTableModel *)rootModel;
    if (rootGroupModel.nextIsShowing == NO) {
        return;
    }
    
    NSInteger rootIndex = [self indexForRoot:rootGroupModel];
    
    if (rootIndex == NSNotFound) {
        return;
    }
    
    NSNumber *sectionNumber = [NSNumber numberWithInteger:rootIndex];
    NSArray *groupModelForRowArray = [groupsDictionary objectForKey:sectionNumber];
    
    NSInteger removeModelIndex = [groupModelForRowArray indexOfObject:removeModel];
    
    if (removeModelIndex == NSNotFound || removeModelIndex < 0) {
        return;
    }
    
    NSMutableArray *groupModelForRowMutableArray = [[NSMutableArray alloc] initWithArray:groupModelForRowArray];
    [groupModelForRowMutableArray removeObject:removeModel];
    [groupsDictionary x_setObject:groupModelForRowMutableArray forKey:sectionNumber];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:removeModelIndex inSection:[sectionNumber integerValue]];
    
    if (_animated == YES) {
        [_tableView beginUpdates];
        [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [_tableView endUpdates];
    } else {
        [_tableView reloadData];
    }
}

#pragma mark reload row

- (void)reloadRootAllRow:(id)rootModel {
    if (rootModel == nil) {
        return;
    }
    
    if ([XTool isDictionaryEmpty:groupsDictionary] == YES) {
        return;
    }
    
    NSInteger waitReloadSection = [self indexForRoot:rootModel];

    if (waitReloadSection == NSNotFound || waitReloadSection < 0 || waitReloadSection >= groupsDictionary.count) {
        return;
    }
    
    XGroupTableModel *groupTableModel = (XGroupTableModel *)rootModel;
    if (groupTableModel.nextIsShowing == NO) {
        return;
    }
    
    NSMutableArray *newGroupModelForRowArray = [[NSMutableArray alloc] init];
    [newGroupModelForRowArray x_addObject:groupTableModel];
    [self reloadRootRowAndChildrenData:groupTableModel storageArray:newGroupModelForRowArray];
    [groupsDictionary x_setObject:newGroupModelForRowArray forKey:[NSNumber numberWithInteger:waitReloadSection]];
    
    [self registerCellClass];
    
    [_tableView reloadData];
}

- (void)reloadRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath == nil) {
        return;
    }
    if (_animated == YES) {
        [_tableView beginUpdates];
        [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [_tableView endUpdates];
    } else {
        [_tableView reloadData];
    }
}

- (void)reloadRowForModel:(id)model {
    if (model == nil) {
        return;
    }
    NSIndexPath *indexPath = [self indexPathForModel:model];
    
    if (indexPath == nil) {
        return;
    }
    
    [self reloadRowAtIndexPath:indexPath];
}

#pragma mark help

- (id)getCellForIndexPath:(NSIndexPath *)indexPath {
    if (_tableView == nil || indexPath == nil) {
        return nil;
    }
    
    id cell = [_tableView cellForRowAtIndexPath:indexPath];
    return cell;
}

- (id)getCellForModel:(id)model {
    return [self getCellForIndexPath:[self indexPathForModel:model]];
}

- (id)getModelAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath == nil) {
        return nil;
    }
    
    if ([XTool isDictionaryEmpty:groupsDictionary] == YES) {
        return nil;
    }
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (section == NSNotFound || section < 0 || section >= groupsDictionary.count ||
        row == NSNotFound || row < 0) {
        return nil;
    }
    
    NSNumber *sectionNumber = [NSNumber numberWithInteger:section];
    NSArray *groupModelForRowArray = [groupsDictionary objectForKey:sectionNumber];
    
    if ([XTool isArrayEmpty:groupModelForRowArray] == YES) {
        return nil;
    }
    
    if (row >= groupModelForRowArray.count) {
        return nil;
    }
    
    return [groupModelForRowArray x_objectAtIndex:row];
}

- (NSIndexPath *)indexPathForModel:(id)model {
    if (model == nil) {
        return nil;
    }
    
    if ([XTool isDictionaryEmpty:groupsDictionary] == YES) {
        return nil;
    }
    
    NSIndexPath *indexPath = nil;
    
    for (NSNumber *sectionNumber in groupsDictionary.allKeys) {
        NSArray *groupModelForRowArray = [groupsDictionary objectForKey:sectionNumber];
        if ([XTool isArrayEmpty:groupModelForRowArray] == NO) {
            NSInteger row = [groupModelForRowArray indexOfObject:model];
            if (row != NSNotFound) {
                NSInteger section = [sectionNumber integerValue];
                indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                return indexPath;
            }
        }
    }
    
    return indexPath;
}

- (NSArray *)getFullGroupItemsForIndexPath:(NSIndexPath *)indexPath {
    id model = [self getModelAtIndexPath:indexPath];
    return [self getFullGroupItems:model];
}

- (NSArray *)getFullGroupItems:(id)model {
    NSIndexPath *indexPath = [self indexPathForModel:model];
    return [self getFullGroupItems:model atIndexPath:indexPath];
}

- (NSArray *)getFullGroupItems:(id)model atIndexPath:(NSIndexPath *)indexPath {
    if (model == nil || indexPath == nil) {
        return nil;
    }
    
    if ([XTool isDictionaryEmpty:groupsDictionary] == YES) {
        return nil;
    }
    
    NSMutableArray *itemsArray = [[NSMutableArray alloc] init];
    [itemsArray x_addObject:model];
    
    NSNumber *sectionNumber = [NSNumber numberWithInteger:indexPath.section];
    
    NSArray *groupModelForRowArray = [groupsDictionary objectForKey:sectionNumber];
    NSInteger fatherLevel = ((XGroupTableModel *)model).level;
    
    for (NSInteger i = indexPath.row - 1; i >= 0; i --) {
        XGroupTableModel *groupTableModel = (XGroupTableModel *)[groupModelForRowArray x_objectAtIndex:i];
        if (groupTableModel.level < fatherLevel) {
            fatherLevel = groupTableModel.level;
            [itemsArray x_insertObject:groupTableModel atIndex:0];
        }
        if (groupTableModel.level == 0) {
            break;
        }
    }
    
    return itemsArray;
}

- (NSInteger)indexForRoot:(id)rootModel {
    if (rootModel == nil || [XTool isDictionaryEmpty:groupsDictionary] == YES) {
        return NSNotFound;
    }
    
    NSInteger rootIndex = NSNotFound;
    for (NSString *sectionNumber in groupsDictionary.allKeys) {
        NSArray *groupModelForRowArray = [groupsDictionary objectForKey:sectionNumber];
        if ([XTool isArrayEmpty:groupModelForRowArray] == NO) {
            id firstModel = [groupModelForRowArray x_objectAtIndex:0];
            if (rootModel == firstModel) {
                rootIndex = [sectionNumber integerValue];
                return rootIndex;
            }
        }
    }
    
    return NSNotFound;
}

- (NSInteger)numberOfRoot {
    if ([XTool isDictionaryEmpty:groupsDictionary] == YES) {
        return 0;
    }
    
    return groupsDictionary.count;
}

- (id)getRootModelAtIndex:(NSInteger)atIndex {
    if ([XTool isDictionaryEmpty:groupsDictionary] == YES) {
        return nil;
    }
    
    if (atIndex < 0 || atIndex == NSNotFound || atIndex >= groupsDictionary.count) {
        return nil;
    }
    
    NSArray *groupModelForRowArray = [groupsDictionary objectForKey:[NSNumber numberWithInteger:atIndex]];
    if ([XTool isArrayEmpty:groupModelForRowArray] == YES) {
        return nil;
    }
    
    return [groupModelForRowArray x_objectAtIndex:0];
}

- (NSArray *)getRootModels {
    if ([XTool isDictionaryEmpty:groupsDictionary] == YES) {
        return nil;
    }
    
    NSMutableArray *rootModels = [[NSMutableArray alloc] init];
    NSInteger rootsCount = groupsDictionary.count;
    for (NSInteger section = 0; section < rootsCount; section ++) {
        NSArray *groupModelForRowArray = [groupsDictionary objectForKey:[NSNumber numberWithInteger:section]];
        if ([XTool isArrayEmpty:groupModelForRowArray] == NO) {
            [rootModels x_addObject:[groupModelForRowArray x_objectAtIndex:0]];
        }
    }
    return rootModels;
}

- (NSArray *)getRootCells {
    if ([XTool isDictionaryEmpty:groupsDictionary] == YES) {
        return nil;
    }
    
    NSMutableArray *rootCells = [[NSMutableArray alloc] init];
    NSInteger rootsCount = groupsDictionary.count;
    for (NSInteger section = 0; section < rootsCount; section ++) {
        NSArray *groupModelForRowArray = [groupsDictionary objectForKey:[NSNumber numberWithInteger:section]];
        if ([XTool isArrayEmpty:groupModelForRowArray] == NO) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
            id cell = [_tableView cellForRowAtIndexPath:indexPath];
            if (cell) {
                [rootCells x_addObject:cell];
            }
        }
    }
    return rootCells;
}

#pragma mark ---------- Private ----------

#pragma mark init

- (void)initialize:(XGroupTableStyle)style {
    [self setBackgroundColor:[UIColor clearColor]];
    
    getNextLevelDataBlock = nil;
    groupsDictionary = [[NSMutableDictionary alloc] init];
    groupTableCellClassesNameDic = [[NSMutableDictionary alloc] init];
    
    _animated = YES;
    _separatorStyle = UITableViewCellSeparatorStyleNone;
    groupTableStyle = style;
}

- (void)loadGroups:(NSArray *)groups {
    if (groupsDictionary == nil) {
        groupsDictionary = [[NSMutableDictionary alloc] init];
    } else {
        [groupsDictionary removeAllObjects];
    }
    
    if (groupTableCellClassesNameDic == nil) {
        groupTableCellClassesNameDic = [[NSMutableDictionary alloc] init];
    } else {
        [groupTableCellClassesNameDic removeAllObjects];
    }

    NSInteger section = 0;
    for (XGroupTableModel *model in groups) {
        NSMutableArray *groupModelForRowArray = [[NSMutableArray alloc] init];
        [groupModelForRowArray x_addObject:model];
        [groupsDictionary x_setObject:groupModelForRowArray forKey:[NSNumber numberWithInteger:section]];

        [self addCellClassesName:model.cellClassName];
        section ++;
    }
}

- (void)addGroupsTableView {
    _tableView = [[XTableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) style:UITableViewStylePlain];
    [_tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_tableView setNoDelaysContentTouches];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    [_tableView setSeparatorStyle:_separatorStyle];
    [self showScrollIndicator:NO];
    [_tableView clearRemainSeparators];
    [self registerCellClass];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [self addSubview:_tableView];
    
    NSLayoutConstraint *_tableViewLeftConstraint = [NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeLeft
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self attribute:NSLayoutAttributeLeft
                                                                     multiplier:1.0f constant:0];
    
    NSLayoutConstraint *_tableViewRightConstraint = [NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeRight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self attribute:NSLayoutAttributeRight
                                                                      multiplier:1.0f constant:0];
    
    NSLayoutConstraint *_tableViewTopConstraint = [NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self attribute:NSLayoutAttributeTop
                                                                    multiplier:1.0f constant:0];
    
    NSLayoutConstraint *_tableViewBottomConstraint = [NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0f constant:0];

    [self addConstraints:@[
                           _tableViewLeftConstraint,
                           _tableViewRightConstraint,
                           _tableViewTopConstraint,
                           _tableViewBottomConstraint
                           ]];
}

#pragma mark property

- (void)setSeparatorStyle:(UITableViewCellSeparatorStyle)separatorStyle {
    _separatorStyle = separatorStyle;
    if (_tableView == nil) {
        return;
    }
    [_tableView setSeparatorStyle:_separatorStyle];
}

#pragma mark method

- (void)addCellClassesName:(NSString *)cellClassName {
    if ([groupTableCellClassesNameDic.allKeys containsObject:cellClassName] == NO) {
        [groupTableCellClassesNameDic x_setObject:[NSNumber numberWithBool:NO] forKey:cellClassName];
    }
}

- (void)registerCellClass {
    if (_tableView == nil) {
        return;
    }
    
    if ([XTool isDictionaryEmpty:groupTableCellClassesNameDic] == YES) {
        return;
    }
    
    for (NSString *cellClassName in groupTableCellClassesNameDic.allKeys) {
        BOOL isRegistered = [[groupTableCellClassesNameDic objectForKey:cellClassName] boolValue];
        if (isRegistered == NO) {
            [_tableView registerClass:NSClassFromString(cellClassName) forCellReuseIdentifier:cellClassName];
            [groupTableCellClassesNameDic x_setObject:[NSNumber numberWithBool:YES] forKey:cellClassName];
        }
    }
}

- (void)openGroupWithTableView:(UITableView *)tableView withIndexPath:(NSIndexPath *)indexPath withModel:(XGroupTableModel *)currentGroupModel {
    if (tableView == nil || indexPath == nil || currentGroupModel == nil) {
        return;
    }

    NSNumber *sectionNumber = [NSNumber numberWithInteger:indexPath.section];
    
    NSMutableArray *groupModelForRowArray = [[NSMutableArray alloc] initWithArray:[groupsDictionary objectForKey:sectionNumber]];
    
    NSInteger currentRow = [groupModelForRowArray indexOfObject:currentGroupModel];
    NSIndexSet *indexSets = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(currentRow + 1, currentGroupModel.nextLevelModels.count)];
    
    [groupModelForRowArray insertObjects:currentGroupModel.nextLevelModels atIndexes:indexSets];
    [groupsDictionary x_setObject:groupModelForRowArray forKey:sectionNumber];
    
    NSMutableArray *indexPathsArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < currentGroupModel.nextLevelModels.count; i++) {
        XGroupTableModel *groupTableModel = [currentGroupModel.nextLevelModels x_objectAtIndex:i];
        [self addCellClassesName:groupTableModel.cellClassName];
        [self registerCellClass];
        NSIndexPath *insertIndexPath = [NSIndexPath indexPathForRow:currentRow + 1 + i inSection:indexPath.section];
        [indexPathsArray x_addObject:insertIndexPath];
    }
    
    if (_animated == YES) {
        [tableView beginUpdates];
        [tableView insertRowsAtIndexPaths:indexPathsArray withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    } else {
        [tableView reloadData];
    }
    
    if (currentGroupModel.level == 0) {
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:_animated];
    } else {
        [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:currentRow + 1 inSection:indexPath.section] atScrollPosition:UITableViewScrollPositionNone animated:_animated];
    }
}

- (void)closeGroupWithTableView:(UITableView *)tableView withIndexPath:(NSIndexPath *)indexPath withModel:(XGroupTableModel *)currentGroupModel {
    if (tableView == nil || indexPath == nil || currentGroupModel == nil) {
        return;
    }
    
    NSNumber *sectionNumber = [NSNumber numberWithInteger:indexPath.section];
    
    NSArray *groupModelForRowArray = [groupsDictionary objectForKey:sectionNumber];
    
    NSMutableArray *waitDeleteModelArray = [[NSMutableArray alloc] init];
    NSMutableArray *waitDeleteIndexPathsArray = [[NSMutableArray alloc] init];
    
    for (NSInteger i = (indexPath.row + 1); i < groupModelForRowArray.count; i++) {
        XGroupTableModel *model = [groupModelForRowArray x_objectAtIndex:i];
        if (model.level > currentGroupModel.level) {
            [model setNextIsShowing:NO];
            [waitDeleteModelArray x_addObject:model];
            NSIndexPath *deleteIndexPath = [NSIndexPath indexPathForRow:i inSection:indexPath.section];
            [waitDeleteIndexPathsArray x_addObject:deleteIndexPath];
        } else {
            break;
        }
    }
    if ([XTool isArrayEmpty:waitDeleteModelArray] == NO) {
        NSMutableArray *groupModelForRowMutableArray = [[NSMutableArray alloc] initWithArray:groupModelForRowArray];
        [groupModelForRowMutableArray removeObjectsInArray:waitDeleteModelArray];
        [groupsDictionary x_setObject:groupModelForRowMutableArray forKey:sectionNumber];
    }
    
    if (_animated == YES) {
        if ([XTool isArrayEmpty:waitDeleteIndexPathsArray] == NO) {
            [tableView beginUpdates];
            [tableView deleteRowsAtIndexPaths:waitDeleteIndexPathsArray withRowAnimation:UITableViewRowAnimationFade];
            [tableView endUpdates];
        }
    } else {
        [tableView reloadData];
    }
}

- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath withCurrentGroupModel:(XGroupTableModel *)currentGroupModel {
    if (indexPath == nil || currentGroupModel == nil) {
        return;
    }
    
    if (currentGroupModel.allowSelect == NO) {
        return;
    }
    
    if(_delegate != nil && [_delegate respondsToSelector:@selector(selectedRow:atIndexPath:model:)]) {
        [_delegate selectedRow:_tableView atIndexPath:indexPath model:currentGroupModel];
    }
    
    if(_delegate != nil && [_delegate respondsToSelector:@selector(fullGroupItemsForSelectedRow:atIndexPath:items:)]) {
        NSArray *itemsArray = [self getFullGroupItems:currentGroupModel atIndexPath:indexPath];
        [_delegate fullGroupItemsForSelectedRow:_tableView atIndexPath:indexPath items:itemsArray];
    }
}

- (void)closeThisGroupOtherSameLevelOrLowerShowingRows:(UITableView *)tableView withIndexPath:(NSIndexPath *)indexPath withModel:(XGroupTableModel *)currentGroupModel {
    if (tableView == nil || indexPath == nil || currentGroupModel == nil) {
        return;
    }
    
    NSMutableArray *waitDeleteIndexPathsArray = [[NSMutableArray alloc] init];
    NSMutableArray *shouldReloadRowIndexPaths = [[NSMutableArray alloc] init];
    NSMutableArray *shouldReloadRowModels = [[NSMutableArray alloc] init];
    
    if (currentGroupModel.level == 0) {
        for (NSNumber *sectionNumber in groupsDictionary.allKeys) {
            NSInteger section = [sectionNumber integerValue];
            if (section != indexPath.section) {
                NSArray *groupModelForRowArray = [groupsDictionary objectForKey:sectionNumber];
                for (NSInteger row = 0; row < groupModelForRowArray.count; row ++) {
                    XGroupTableModel *model = [groupModelForRowArray objectAtIndex:row];
                    if (model.nextIsShowing == YES) {
                        [model setNextIsShowing:NO];
                        
                        if (row == 0) {
                            NSIndexPath *shouldReloadRowIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
                            [shouldReloadRowIndexPaths x_addObject:shouldReloadRowIndexPath];
                            [shouldReloadRowModels x_addObject:model];
                        }
                    }
                    
                    if (row != 0) {
                        NSIndexPath *waitDeleteIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
                        [waitDeleteIndexPathsArray x_addObject:waitDeleteIndexPath];
                    }
                }
                if (groupModelForRowArray.count > 1) {
                    NSMutableArray *newGroupModelForRowArray = [[NSMutableArray alloc] init];
                    [newGroupModelForRowArray x_addObject:[groupModelForRowArray x_objectAtIndex:0]];
                    [groupsDictionary x_setObject:newGroupModelForRowArray forKey:sectionNumber];
                }
            }
        }
        
        
    } else {
        NSNumber *sectionNumber = [NSNumber numberWithInteger:indexPath.section];
        
        NSArray *groupModelForRowArray = [groupsDictionary objectForKey:sectionNumber];
        
        NSMutableArray *waitDeleteModelArray = [[NSMutableArray alloc] init];
        
        for (NSInteger row = 0; row < groupModelForRowArray.count; row ++) {
            XGroupTableModel *model = [groupModelForRowArray x_objectAtIndex:row];
            if (model.level == currentGroupModel.level) {
                if (model != currentGroupModel && model.nextIsShowing == YES) {
                    [model setNextIsShowing:NO];
                    NSIndexPath *shouldReloadRowIndexPath = [NSIndexPath indexPathForRow:row inSection:indexPath.section];
                    [shouldReloadRowIndexPaths x_addObject:shouldReloadRowIndexPath];
                    [shouldReloadRowModels x_addObject:model];
                }
            } else if (model.level > currentGroupModel.level) {
                [model setNextIsShowing:NO];
                [waitDeleteModelArray x_addObject:model];
                
                NSIndexPath *waitDeleteIndexPath = [NSIndexPath indexPathForRow:row inSection:indexPath.section];
                [waitDeleteIndexPathsArray x_addObject:waitDeleteIndexPath];
            }
        }
        
        if ([XTool isArrayEmpty:waitDeleteModelArray] == NO) {
            NSMutableArray *groupModelForRowMutableArray = [[NSMutableArray alloc] initWithArray:groupModelForRowArray];
            [groupModelForRowMutableArray removeObjectsInArray:waitDeleteModelArray];
            [groupsDictionary x_setObject:groupModelForRowMutableArray forKey:sectionNumber];
        }
    }
    
    if ([XTool isArrayEmpty:shouldReloadRowIndexPaths] == NO &&
        [XTool isArrayEmpty:shouldReloadRowModels] == NO &&
        shouldReloadRowIndexPaths.count == shouldReloadRowModels.count) {
        
        if(_delegate != nil && [_delegate respondsToSelector:@selector(shouldUpdateRow:atIndexPath:model:)]) {
            for (NSInteger i=0; i<shouldReloadRowIndexPaths.count; i++) {
                NSIndexPath *shouldReloadRowIndexPath = [shouldReloadRowIndexPaths objectAtIndex:i];
                id shouldReloadRowModel = [shouldReloadRowModels objectAtIndex:i];
                [_delegate shouldUpdateRow:tableView atIndexPath:shouldReloadRowIndexPath model:shouldReloadRowModel];
            }
        }
        
    }
    
    if ([XTool isArrayEmpty:waitDeleteIndexPathsArray] == NO) {
        if (_animated == YES) {
            [tableView beginUpdates];
            [tableView deleteRowsAtIndexPaths:waitDeleteIndexPathsArray withRowAnimation:UITableViewRowAnimationFade];
            [tableView endUpdates];
        } else {
            [tableView reloadData];
        }
    }
}

- (void)reloadRootRowAndChildrenData:(XGroupTableModel *)model storageArray:(NSMutableArray *)storageArray {
    if (model == nil) {
        return;
    }

    [self addCellClassesName:model.cellClassName];

    if ([XTool isArrayEmpty:model.nextLevelModels] == YES) {
        return;
    }

    for (XGroupTableModel *subModel in model.nextLevelModels) {
        if (subModel.nextIsShowing == NO) {
            [self addCellClassesName:subModel.cellClassName];
            [storageArray x_addObject:subModel];
        } else {
            [self reloadRootRowAndChildrenData:subModel storageArray:storageArray];
        }
    }
}

#pragma mark TableView DataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sectionsCount = 0;
    
    if ([XTool isDictionaryEmpty:groupsDictionary] == YES) {
        return sectionsCount;
    }
    
    sectionsCount = groupsDictionary.count;

    return sectionsCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rowsCount = 0;
    
    if ([XTool isDictionaryEmpty:groupsDictionary] == YES) {
        return rowsCount;
    }
    
    NSArray *groupModelForRowArray = [groupsDictionary objectForKey:[NSNumber numberWithInteger:section]];
    if ([XTool isArrayEmpty:groupModelForRowArray] == YES) {
        return rowsCount;
    }
    
    rowsCount = groupModelForRowArray.count;
    
    return rowsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XGroupTableCell *cell = nil;
    
    if ([XTool isDictionaryEmpty:groupsDictionary] == YES) {
        return cell;
    }
    
    NSArray *groupModelForRowArray = [groupsDictionary objectForKey:[NSNumber numberWithInteger:indexPath.section]];
    if ([XTool isArrayEmpty:groupModelForRowArray] == YES) {
        return cell;
    }
    
    XGroupTableModel *model = (XGroupTableModel *)[groupModelForRowArray x_objectAtIndex:indexPath.row];
    if (model == nil) {
        return cell;
    }
    
    if ([XTool isStringEmpty:model.cellClassName] == YES) {
        return cell;
    }
    
    cell = (XGroupTableCell *)[tableView dequeueReusableCellWithIdentifier:model.cellClassName forIndexPath:indexPath];
    [cell setDelegate:_delegate];
    [cell addModel:model];

    return cell;
}

#pragma mark TableView Delegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat rowHeight = 0;
    
    if ([XTool isDictionaryEmpty:groupsDictionary] == YES) {
        return rowHeight;
    }
    
    NSArray *groupModelForRowArray = [groupsDictionary objectForKey:[NSNumber numberWithInteger:indexPath.section]];
    if ([XTool isArrayEmpty:groupModelForRowArray] == YES) {
        return rowHeight;
    }
    
    XGroupTableModel *model = (XGroupTableModel *)[groupModelForRowArray x_objectAtIndex:indexPath.row];
    if (model == nil) {
        return rowHeight;
    }

    if ([XTool isStringEmpty:model.cellClassName] == YES) {
        return rowHeight;
    }
    
    rowHeight = [NSClassFromString(model.cellClassName) getCellHeight:model width:tableView.frame.size.width];
    
    return rowHeight;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([XTool isDictionaryEmpty:groupsDictionary] == YES) {
        return nil;
    }
    
    NSArray *groupModelForRowArray = [groupsDictionary objectForKey:[NSNumber numberWithInteger:indexPath.section]];
    if ([XTool isArrayEmpty:groupModelForRowArray] == YES) {
        return nil;
    }
    
    XGroupTableModel *model = (XGroupTableModel *)[groupModelForRowArray x_objectAtIndex:indexPath.row];
    if (model == nil) {
        return nil;
    }
    
    if (model.allowSelect == YES) {
        return indexPath;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    XGroupTableCell *cell = (XGroupTableCell *)[tableView cellForRowAtIndexPath:indexPath];
    [self selectRowAtIndexPath:indexPath withCurrentGroupModel:cell.currentGroupTableModel];
}

@end
