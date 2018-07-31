//
//  ViewController.m
//  AVPlayerIntroduce
//
//  Created by fuhang on 2018/7/31.
//  Copyright © 2018年 wechat. All rights reserved.
//

#import "ViewController.h"

// 导入AVFoundation框架
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *strURL = @"https://www.apple.com/105/media/cn/home/2018/da585964_d062_4b1d_97d1_af34b440fe37/films/behind-the-mac/mac-behind-the-mac-tpl-cn_848x480.mp4";
    NSURL *url = [NSURL URLWithString:strURL];
    AVURLAsset *asset = [AVURLAsset assetWithURL:url];
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    // 暂停的时候不能继续缓冲
    item.canUseNetworkResourcesForLiveStreamingWhilePaused = NO;
    if (@available(iOS 10.0, *)) {
        // 提前缓冲1s
        item.preferredForwardBufferDuration = 1.0;
    }
   
    AVPlayer *player = [AVPlayer playerWithPlayerItem:item];
    if (@available(iOS 10.0, *)) {
         // 网络不好的时候，不允许降低播放速度
        player.automaticallyWaitsToMinimizeStalling = NO;
    }
    AVPlayerLayer *avLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    // 适配avLayer的时候，视频的长宽比例不能改变。这样如果视频和avLayer的长宽比例不一致，就会留空白。
    avLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    avLayer.frame = self.view.bounds;
    
    [self.view.layer addSublayer:avLayer];
    
    // 播放视频
    [player play];
}

@end
