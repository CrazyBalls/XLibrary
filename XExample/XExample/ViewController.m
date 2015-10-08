//
//  ViewController.m
//  XExample
//
//  Created by XJY on 15/9/19.
//  Copyright © 2015年 XJY. All rights reserved.
//

#import "ViewController.h"
#import <XFramework/XFramework.h>
#import "TestModel.h"

@interface ViewController () <XGroupTableDelegate, UIWebViewDelegate> {
}

@property (strong, nonatomic) IBOutlet UIButton *clickbutton;

@end

@implementation ViewController {
    XGroupTable *groupTable;
    NSMutableArray *rootArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    rootArray = [NSMutableArray array];
    for (int i = 0; i < 10; i++) {
        TestModel *rootModel = [[TestModel alloc] initWithLevel:0 nextLevelModels:@[] cellClassName:@"TestCell"];
        [rootModel setText:[NSString stringWithFormat:@"%@ %d", @"Root", i]];
        [rootModel setBgColor:[UIColor redColor]];
        [rootModel setAllowSelect:YES];
        
        [rootArray addObject:rootModel];
    }

    groupTable = [[XGroupTable alloc] initWithGroups:rootArray style:XGroupTableStyleSingle];
    [groupTable setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [groupTable setFrame:CGRectMake(0, 80, self.view.frame.size.width, self.view.frame.size.height - 80)];
    [groupTable setDelegate:self];
    [groupTable showScrollIndicator:YES];
    [self.view addSubview:groupTable];
    
    [groupTable.tableView headerWithRefreshingBlock:^{
        [groupTable.tableView endRefresh:XRefreshingTypeHeader];
    }];
    
    [groupTable.tableView footerWithRefreshingBlock:^{
        [groupTable.tableView endRefresh:XRefreshingTypeFooter];
    }];
    
    [groupTable.tableView setRefreshTitleForStateIdle:@"123" forRefresh:XRefreshingTypeFooter];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)deleteButton:(id)sender {
    [groupTable removeRowAtIndex:0 rootModel:[rootArray objectAtIndex:0] fatherModel:[rootArray objectAtIndex:0]];
//    [groupTable removeRowForModel:subModel rootModel:[rootArray objectAtIndex:0] fatherModel:[rootArray objectAtIndex:0]];
}


- (IBAction)clickEvent:(id)sender {
//    [groupTable removeRootAtIndex:9];
//    [groupTable removeLastRoot];
//    [rootArray removeObjectAtIndex:rootArray.count - 1];
    TestModel *subModel = [[TestModel alloc] initWithLevel:1 nextLevelModels:@[] cellClassName:@"TestCell"];
    [subModel setText:[NSString stringWithFormat:@"%@ %d", @"SubCell", 0]];
    [subModel setBgColor:[UIColor yellowColor]];
    [subModel setAllowSelect:YES];

    [groupTable insertRowForModel:subModel rootModel:[rootArray objectAtIndex:0] fatherModel:[rootArray objectAtIndex:0]];
    
}

#pragma mark delegate

- (void)selectedRow:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath model:(id)model {
    [groupTable didSelectRowAtIndexPath:indexPath];
}

- (void)fullGroupItemsForSelectedRow:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath items:(NSArray *)items {
    
}

- (void)shouldUpdateRow:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath model:(id)model {
    
}

@end
