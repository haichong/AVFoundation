//
//  FHSamplePlayerViewController.m
//  AVPlayerIntroduce
//
//  Created by fuhang on 2018/7/31.
//  Copyright © 2018年 wechat. All rights reserved.
//

#import "FHSamplePlayerViewController.h"

// 导入AVFoundation框架
#import <AVFoundation/AVFoundation.h>

@interface FHSamplePlayerViewController ()
{
    id _timeObserver;
    id _itmePlaybackEndObserver;
}

// 播放资源：只包含媒体资源的静态信息
@property (nonatomic, strong) AVURLAsset *asset;
// 播放单元：包含媒体资源的动态信息：是否可以播放，播放进度，缓存进度，视屏的尺寸，是否播放完，缓冲情况（可以正常播放还是网络情况不好）
@property (nonatomic, strong) AVPlayerItem *playerItem;
// 播放器
@property (nonatomic, strong) AVPlayer *player;
// 播放器界面
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@end

@implementation FHSamplePlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initPlayer];
}

- (void)initPlayer
{
    NSString *strURL = @"https://www.apple.com/105/media/cn/home/2018/da585964_d062_4b1d_97d1_af34b440fe37/films/behind-the-mac/mac-behind-the-mac-tpl-cn_848x480.mp4";
    NSURL *url = [NSURL URLWithString:strURL];
    AVURLAsset *asset = [AVURLAsset assetWithURL:url];
    self.asset = asset;
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    // 暂停的时候不能继续缓冲
    item.canUseNetworkResourcesForLiveStreamingWhilePaused = NO;
    if (@available(iOS 10.0, *)) {
        // 提前缓冲1s
        item.preferredForwardBufferDuration = 1.0;
    }
    self.playerItem = item;
    
    AVPlayer *player = [AVPlayer playerWithPlayerItem:item];
    if (@available(iOS 10.0, *)) {
        // 网络不好的时候，不允许降低播放速度
        player.automaticallyWaitsToMinimizeStalling = NO;
    }
    self.player = player;
    
    AVPlayerLayer *avLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    // 适配avLayer的时候，视频的长宽比例不能改变。这样如果视频和avLayer的长宽比例不一致，就会留空白。
    avLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    avLayer.frame = self.view.bounds;
    
    [self.view.layer addSublayer:avLayer];
    self.playerLayer = avLayer;
    
    // 播放视频
    [player play];
    
    [self addObserver];
}

- (void)stop
{
    [self.player pause];
    
    [self.player removeTimeObserver:_timeObserver];
    _timeObserver = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    _itmePlaybackEndObserver = nil;
    
    self.player = nil;
    self.playerItem = nil;
    self.asset = nil;
    [self.playerLayer removeFromSuperlayer];
    
    [self removeObserver];
}

- (void)addObserver
{
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"presentationSize" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    
    CMTime interval = CMTimeMakeWithSeconds(0.5, NSEC_PER_SEC);
    __weak FHSamplePlayerViewController *weakSelf= self;
    // 增加播放进度的监听 每0.5秒调用一次
    _timeObserver = [self.player addPeriodicTimeObserverForInterval:interval queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        if (!weakSelf) return;
        NSArray *loadedRanges = weakSelf.playerItem.seekableTimeRanges;
        if (loadedRanges.count > 0 && weakSelf.playerItem.duration.timescale != 0) {
            NSLog(@"播放进度 = %.2f",CMTimeGetSeconds(time));
            NSLog(@"视频总时长 = %.2f",CMTimeGetSeconds(weakSelf.playerItem.duration));
        }
    }];
    
    // 增加播放结束的监听
    _itmePlaybackEndObserver = [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        NSLog(@"本视频播放结束了");
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    
    if ([keyPath isEqualToString:@"status"]) {
        switch (self.playerItem.status) {
            case AVPlayerItemStatusUnknown:
                NSLog(@"未知的播放状态");
                break;
            case AVPlayerItemStatusReadyToPlay:
                NSLog(@"马上可以播放了");
                break;
            case AVPlayerItemStatusFailed:
                NSLog(@"发生错误：%@",self.player.error);
                break;
            default:
                break;
        }
    }
    
    if ([keyPath isEqualToString:@"presentationSize"]) {
        NSLog(@"视频的尺寸：%@",NSStringFromCGSize(self.playerItem.presentationSize));
    }
    
    if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSLog(@"缓冲进度：%.2f",[self loadedTime]);

    }
    
    if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        NSLog(@"%@可以正常播放",self.playerItem.playbackLikelyToKeepUp ? @"" : @"不");
    }
    
    if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        NSLog(@"%@有缓冲",self.playerItem.playbackBufferEmpty ? @"没": @"");
    }
}

- (void)removeObserver
{
    @try{
        [self.playerItem removeObserver:self forKeyPath:@"status"];
        [self.playerItem removeObserver:self forKeyPath:@"presentationSize"];
        [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
        [self.playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    } @catch(NSException *e){
        NSLog(@"failed to remove observer");
    }
}

// 获取缓存的进度
- (NSTimeInterval)loadedTime {
    
    NSArray *timeRanges = _playerItem.loadedTimeRanges;
    // 播放的进度
    CMTime currentTime = _player.currentTime;
    
    // 判断播放的进度是否在缓存的进度内
    BOOL included = NO;
    CMTimeRange firstTimeRange = {0};
    if (timeRanges.count > 0) {
        firstTimeRange = [[timeRanges objectAtIndex:0] CMTimeRangeValue];
        if (CMTimeRangeContainsTime(firstTimeRange, currentTime)) {
            included = YES;
        }
    }
    
    // 存在返回缓存的进度
    if (included) {
        CMTime endTime = CMTimeRangeGetEnd(firstTimeRange);
        NSTimeInterval loadedTime = CMTimeGetSeconds(endTime);
        if (loadedTime > 0) {
            return loadedTime;
        }
    }
    return 0;
}

- (void)dealloc
{
    [self stop];
    NSLog(@"%@ dealloc",[self class]);
}

@end
