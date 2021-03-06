//
//  FunctionListViewController.m
//  AVPlayerIntroduce
//
//  Created by fuhang on 2018/7/31.
//  Copyright © 2018年 wechat. All rights reserved.
//

#import "FHFunctionListViewController.h"

#import "FHSamplePlayerViewController.h"

static NSString *const CellID = @"CellID";

@interface FHFunctionListViewController ()

@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSArray *viewControllers;

@end

@implementation FHFunctionListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"功能列表";
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
        _viewControllers = @[[FHSamplePlayerViewController class]];
    }
    return _viewControllers;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    NSLog(@"didReceiveMemoryWarning");
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
    UIViewController *vc = [self.viewControllers[indexPath.row] new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)shouldAutorotate {
    return NO;
}

@end
