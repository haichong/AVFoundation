//
//  AppDelegate.m
//  AVPlayerIntroduce
//
//  Created by fuhang on 2018/7/31.
//  Copyright © 2018年 wechat. All rights reserved.
//

#import "AppDelegate.h"

#import "FHNavigationController.h"
#import "FHFunctionListViewController.h"

#import "UMCommon/UMCommon.h"
#import "UMCommonLog/UMCommonLogManager.h"
#import "UMAnalytics/MobClick.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
   
    [self initWindow];
    [self initRootVC];
    [self registerUM];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)initWindow
{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
}

- (void)initRootVC
{
    FHFunctionListViewController *vc = [FHFunctionListViewController new];
    FHNavigationController *nav = [[FHNavigationController alloc] initWithRootViewController: vc];
    self.window.rootViewController = nav;
}

- (void)registerUM
{
    [MobClick setScenarioType:E_UM_NORMAL];
    [MobClick setCrashReportEnabled:YES];
    [UMConfigure setLogEnabled:YES];
    [UMConfigure setEncryptEnabled:NO];
    [UMCommonLogManager setUpUMCommonLogManager];
    [UMConfigure setLogEnabled:YES];
    [UMConfigure initWithAppkey:@"5b8512fff29d9851c8000012" channel:@"App Store"];
}

@end
