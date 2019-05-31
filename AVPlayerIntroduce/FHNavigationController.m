//
//  FHNavigationController.m
//  AVPlayerIntroduce
//
//  Created by fuhang on 2018/8/27.
//  Copyright © 2018年 wechat. All rights reserved.
//

#import "FHNavigationController.h"

@interface FHNavigationController ()

@end

@implementation FHNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
  修改[UIApplication sharedApplication].statusBarOrientation = interfaceOrientation;设置无效的bug
 如果window.rootViewController是一个容器视图，例如UINavigationController，UITabBarController,默认走的是容器视图下面的方法，我们要设置成走对应视图的方法。
 **/
// 是否支持屏幕旋转
- (BOOL)shouldAutorotate {
    return [self.topViewController shouldAutorotate];
}

// 支持的屏幕旋转方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.topViewController supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [self.topViewController preferredInterfaceOrientationForPresentation];
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.topViewController;
}

@end
