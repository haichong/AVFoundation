//
//  FunctionListViewController.m
//  AVPlayerIntroduce
//
//  Created by fuhang on 2018/7/31.
//  Copyright © 2018年 wechat. All rights reserved.
//

#import "FunctionListViewController.h"

#import "FHSamplePlayerViewController.h"

static NSString *const CellID = @"CellID";

@interface FunctionListViewController ()

@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSArray<UIViewController *> *viewControllers;

@end

@implementation FunctionListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (NSArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = @[@"1.做一个最简单的播放器"];
    }
    return _dataSource;
}

- (NSArray<UIViewController *> *)viewControllers
{
    if (!_viewControllers) {
        _viewControllers = @[[FHSamplePlayerViewController new]];
    }
    return _viewControllers;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
    }
    
    cell.textLabel.text = self.dataSource[0];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *vc = self.viewControllers[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}




@end
