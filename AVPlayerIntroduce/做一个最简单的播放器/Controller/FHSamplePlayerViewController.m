//
//  FHSamplePlayerViewController.m
//  AVPlayerIntroduce
//
//  Created by fuhang on 2018/7/31.
//  Copyright © 2018年 wechat. All rights reserved.
//
//


#import "FHSamplePlayerViewController.h"

// 导入AVFoundation框架
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "VideoRequestTask.h"
#import "LoaderURLConnection.h"

#import "FHControlView.h"

#define SCREEN_WIDTH  UIScreen.mainScreen.bounds.size.width
#define SCREEN_HEIGHT UIScreen.mainScreen.bounds.size.height

@interface FHPlayerPresentView : UIView

@property (nonatomic, strong) AVPlayer *player;
/// default is AVLayerVideoGravityResizeAspect.
@property (nonatomic, strong) AVLayerVideoGravity videoGravity;


@end

@implementation FHPlayerPresentView

/*
 + (Class)layerClass;
 - (AVPlayerLayer *)avLayer;
 - (void)setPlayer:(AVPlayer *)player;
 这三个方法相当于下面的方法
 [self.layer addSublayer:avPlayerLayer];
 **/

// 重写+layerClass方法使得在创建的时候能返回一个不同的图层子类。UIView会在初始化的时候调用+layerClass方法，然后用它的返回类型来创建宿主图层
+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

- (AVPlayerLayer *)avLayer
{
    return (AVPlayerLayer *)self.layer;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (void)setPlayer:(AVPlayer *)player
{
    if (player == _player) {return;}
    self.avLayer.player = player;
}

- (void)setVideoGravity:(AVLayerVideoGravity)videoGravity
{
    if (videoGravity == self.videoGravity) {return;}
    [self avLayer].videoGravity = videoGravity;
}

- (AVLayerVideoGravity)videoGravity
{
    return [self avLayer].videoGravity;
}

@end


@interface FHSamplePlayerViewController ()<AVAssetResourceLoaderDelegate, AVAssetResourceLoaderDelegate,  VideoRequestTaskDelegate>
{
    id _timeObserver;
    id _itmePlaybackEndObserver;
}

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) FHControlView *controlView;
@property (strong, nonatomic) FHPlayerPresentView *presentView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) NSMutableArray *pendingRequests;

// 播放资源：只包含媒体资源的静态信息
@property (nonatomic, strong) AVURLAsset *asset;
// 播放单元：包含媒体资源的动态信息：是否可以播放，播放进度，缓存进度，视屏的尺寸，是否播放完，缓冲情况（可以正常播放还是网络情况不好）
@property (nonatomic, strong) AVPlayerItem *playerItem;
// 播放器
@property (nonatomic, strong) AVPlayer *player;
// 播放器界面
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

// 是否正在播放
@property (nonatomic, assign) BOOL playing;

@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, assign) BOOL isFullScreen;

@property (nonatomic, assign) BOOL isDragging;

@property (nonatomic, copy) NSString *videoPath;

@property (nonatomic, strong) LoaderURLConnection *resouerLoader;


@end

@implementation FHSamplePlayerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _currentIndex = 0;

    [self initPlayer];
    [self initUI];
}

// 初始化播放器
- (void)initPlayer
{
    /*
     当视频播放一次之后 就用这个，播放本地的视频
     建议用模拟器运行项目，这样可以清楚的看到保存的视频
     **/
    NSLog(@"视频保存的位置 = %@", self.videoPath);
    // 本地视频的播放url
    NSURL *localUrl = [NSURL fileURLWithPath:self.videoPath];
    // 在线视频的播放url
    NSURL *url = self.dataSource[_currentIndex];
    
    NSURL *assetUrl = url; //localUrl; 
    NSString *str = [assetUrl absoluteString];
//    if ([str hasPrefix:@"http"])
//    {
//        /*
//         LoaderURLConnection：self.asset.resourceLoader的代理
//         **/
//        self.resouerLoader = [[LoaderURLConnection alloc] init];
//        NSURL *playUrl = [self.resouerLoader getSchemeVideoURL:assetUrl];
//        self.asset = [AVURLAsset URLAssetWithURL:playUrl options:nil];
//        /*
//         delegate：代理必须传一个新的对象，不能用self，否则代理的方法不执行，视频也不播放
//         delegateQueue：必须主队列，否则崩溃
//         **/
//        [self.asset.resourceLoader setDelegate:self.resouerLoader queue:dispatch_get_main_queue()];
//    }
//    else
//    {
//        self.asset = [AVURLAsset URLAssetWithURL:assetUrl options:nil];
//
//    }
    self.asset = [AVURLAsset URLAssetWithURL:assetUrl options:nil];

    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:self.asset];
    // 暂停的时候不能继续缓冲
    item.canUseNetworkResourcesForLiveStreamingWhilePaused = NO;
    if (@available(iOS 10.0, *))
    {
        // 提前缓冲10s
        item.preferredForwardBufferDuration = 10.0;
    }
    self.playerItem = item;
    
    AVPlayer *player = [AVPlayer playerWithPlayerItem:item];
    if (@available(iOS 10.0, *))
    {
        // 网络不好的时候，不允许降低播放速度
        player.automaticallyWaitsToMinimizeStalling = NO;
    }
    self.player = player;
    
    
    //    AVPlayerLayer *avLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    //    // 适配avLayer的时候，视频的长宽比例不能改变。这样如果视频和avLayer的长宽比例不一致，就会留空白。
    //    avLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    //    avLayer.frame = self.containerView.bounds;
    //
    //    [self.containerView.layer addSublayer:avLayer];
    //  self.playerLayer = avLayer;
    
    FHPlayerPresentView *presentView = [[FHPlayerPresentView alloc] initWithFrame:self.containerView.bounds];

    [self.containerView addSubview:presentView];
    presentView.player = self.player;
    self.presentView = presentView;
    
    // 保持containerView在最上层，这样就可以控制视频的播放了。
    [presentView addSubview:self.controlView];
    [self updateControlViewConstraint];
    
    [self play];
    [self addObserver];
}

// 播放视频
- (void)play
{
    self.titleLabel.text = [NSString stringWithFormat:@"视频%zd",_currentIndex + 1];
    self.playing = YES;
    [self.player play];
    [self updateControlViewPlayStatus];
}

- (void)initControlViewStatus {
    [self.controlView initControlStatus];
}

// 停止播放视频
- (void)stop
{
    // 暂停播放视频
    [self.player pause];
    // 记录视频的播放状态
    self.playing = NO;
    
    // 移除观察者
    [self.player removeTimeObserver:_timeObserver];
    // 一定要取消player的当前PlayerItem，负责会造成内存泄漏，且没有提示
    // 多次切换PlayerItem就会崩溃
    [self.player replaceCurrentItemWithPlayerItem:nil];
    _timeObserver = nil;
   
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
     _itmePlaybackEndObserver = nil;
   
    // 移除KVO
    // 必须先移除KVO，在释放playerItem，否则多初始化几次播放器，就会崩溃，而且没有错误日志。
    [self removeObserver];
    
    // 释放视频相关对象
    self.player = nil;
    self.playerItem = nil;
    self.asset = nil;
    [self.playerLayer removeFromSuperlayer];
    
}

- (void)addObserver
{
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"presentationSize" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    
    // 表示0.5s
    CMTime interval = CMTimeMakeWithSeconds(0.5, NSEC_PER_SEC);
    __weak typeof(self) weakSelf = self;
    // 增加播放进度的监听 每0.5秒调用一次
    _timeObserver = [self.player addPeriodicTimeObserverForInterval:interval queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        if (!weakSelf) return;
        NSArray *loadedRanges = weakSelf.playerItem.seekableTimeRanges;
        if (loadedRanges.count > 0 && weakSelf.playerItem.duration.timescale != 0)
        {
            if (!weakSelf.isDragging)
            {
                // 播放的时间
                CGFloat currentTime = CMTimeGetSeconds(time);
                // 视频总长度
                CGFloat duration = CMTimeGetSeconds(weakSelf.playerItem.duration);
                weakSelf.controlView.playTimeLabel.text = [weakSelf formatSeconds:currentTime];
                weakSelf.controlView.totalTimeLabel.text = [weakSelf formatSeconds:duration];
                 weakSelf.controlView.playSlider.value = currentTime / duration;
            }
           
        }
    }];
    
    // 增加播放结束的监听
    _itmePlaybackEndObserver = [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        NSLog(@"本视频播放结束了");
        // 播放结束之后，播放下一个；列表循环
        //[weakSelf playTheNext:nil];
    }];
}

- (NSString *)formatSeconds:(CGFloat)seconds
{
    NSInteger s = seconds;
    NSInteger minute = s / 60;
    NSInteger second = s % 60;
    
    return [NSString stringWithFormat:@"%.2ld:%.2ld",(long)minute,(long)second];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    
    if ([keyPath isEqualToString:@"status"])
    {
        switch (self.playerItem.status)
        {
            case AVPlayerItemStatusUnknown:
                NSLog(@"未知的播放状态");
                break;
            case AVPlayerItemStatusReadyToPlay:
                NSLog(@"马上可以播放了");
                if (self.playing)
                {
                    [self play];
                }
                break;
            case AVPlayerItemStatusFailed:
                NSLog(@"发生错误：%@",self.player.error);
                break;
            default:
                break;
        }
    }
    
    if ([keyPath isEqualToString:@"presentationSize"])
    {
        NSLog(@"视频的尺寸：%@",NSStringFromCGSize(self.playerItem.presentationSize));
    }
    
    if ([keyPath isEqualToString:@"loadedTimeRanges"])
    {
        //NSLog(@"缓冲进度：%.2f",[self loadedTime]);
        CGFloat loadedTime = [self loadedTime];
        CGFloat duration = CMTimeGetSeconds(self.playerItem.duration);
        self.controlView.loadedProgress.progress = loadedTime / duration;
    }
    
    if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"])
    {
        NSLog(@"%@可以正常播放",self.playerItem.playbackLikelyToKeepUp ? @"" : @"不");
        
        // 当由于某种原因（eg，没有缓冲）不能继续播放了，视频会自动暂停
        // 但当有缓冲的时候却不会自动播放，所有我们要让视频继续播放
//        if (self.playerItem.playbackLikelyToKeepUp && self.playing)
//        {
//            [self play];
//        }
        [self play];
    }
    
    if ([keyPath isEqualToString:@"playbackBufferEmpty"])
    {
        NSLog(@"%@有缓冲",self.playerItem.playbackBufferEmpty ? @"没": @"");
        if (self.playerItem.playbackBufferEmpty)
        {
            [self buffingSomeSeconds];
        }
    }
}

- (void)removeObserver
{
    // 防止删除不存在的观察者，崩溃
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
- (NSTimeInterval)loadedTime
{
    
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

// 当网络不好的时候，会多次调用这里，
- (void)buffingSomeSeconds
{
    // 需要先暂停一小会之后再播放，否则网络状况不好的时候时间在走，声音播放不出来
    [self.player pause];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 如果此时用户已经暂停了，则不再需要开启播放了
        if (!self.playing) {return;}
        
        [self play];
        // 如果执行了play还是没有播放则说明还没有缓存好，则再次缓存一段时间
        if (!self.playerItem.isPlaybackLikelyToKeepUp)
        {
            [self buffingSomeSeconds];
        }
    });
}


- (IBAction)playTheLast:(id)sender
{
    _currentIndex--;
    if (_currentIndex < 0 || self.dataSource.count == 0 || _currentIndex >= self.dataSource.count){return;}
    
    [self stop];
    [self initPlayer];
}

- (IBAction)playTheNext:(id)sender
{
    _currentIndex++;
    
    if (_currentIndex < 0 || self.dataSource.count == 0) {return;}
    
    if ( _currentIndex >= self.dataSource.count)
    {
        _currentIndex = 0;
    }
    
    [self stop];
    [self initPlayer];
}


- (NSArray *)dataSource
{
    if (!_dataSource)
    {
        _dataSource = @[[NSURL URLWithString:@"https://www.apple.com/105/media/us/iphone-11-pro/2019/3bd902e4-0752-4ac1-95f8-6225c32aec6d/films/demo/iphone-11-pro-demo-tpl-cc-us-2019_1280x720h.mp4"],[NSURL URLWithString:@"https://www.apple.com/105/media/cn/iphone-x/2017/01df5b43-28e4-4848-bf20-490c34a926a7/films/feature/iphone-x-feature-cn-20170912_848x480.mp4"],[NSURL URLWithString:@"https://www.apple.com/105/media/cn/home/2018/da585964_d062_4b1d_97d1_af34b440fe37/films/behind-the-mac/mac-behind-the-mac-tpl-cn_848x480.mp4"]];
        
    }
    
    return _dataSource;
}

// 控制视频播放
- (void)controlAction:(UIButton *)button
{
    // 记录播放的状态
    self.playing = !self.playing;
    // 如果视频正在播放，暂停；否则，播放。
    if (!self.playing)
    {
        // 暂停
        [self.player pause];
    }
    else
    {
        //播放
        [self play];
    }
    
    [self updateControlViewPlayStatus];
}

- (void)updateControlViewPlayStatus
{
    // 修改button的图标
    NSString *imageName = self.playing ? @"pause" : @"play";
    [self.controlView.playBtn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

- (void)fullScreanAction:(UIButton *)button
{
    [self changeInterfaceOrientation:self.isFullScreen ? UIInterfaceOrientationPortrait : UIInterfaceOrientationLandscapeRight];
}

// 旋转屏幕，interfaceOrientation要旋转的方向
- (void)changeInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // 父视图
    UIView *superView = nil;
    // 旋转的角度，默认值是恢复原来的样式
    CGAffineTransform  transform = CGAffineTransformIdentity;
    
    // 竖屏 -> 横屏
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        // 父视图是keyWindow
        superView = [[UIApplication sharedApplication] keyWindow];
        
        // HOME键在左边，逆时针旋转90°
        if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
            transform = CGAffineTransformMakeRotation(-M_PI_2);
            
        }else if(interfaceOrientation == UIInterfaceOrientationLandscapeRight){
            // HOME键在右边，顺时针旋转90°
            transform = CGAffineTransformMakeRotation(M_PI_2);
        }
        // 记录界面的状态
        self.isFullScreen = YES;
        
    }else{
        // 横屏 -> 竖屏
        superView = self.containerView;
        transform = CGAffineTransformIdentity;
        self.isFullScreen = NO;
    }
    
    [superView addSubview:self.presentView];
    
    // 修改界面的方向
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    /*
     * 设置- (BOOL)shouldAutorotate{return NO;}才有效
     */
    [UIApplication sharedApplication].statusBarOrientation = interfaceOrientation;
#pragma clang diagnostic pop
    // 标记界面的方向需要更改
    [self setNeedsStatusBarAppearanceUpdate];
    
    // 旋转动画
    [UIView animateWithDuration:0.25 animations:^{
        // 旋转
        self.presentView.transform = transform;
        [UIView animateWithDuration:0.25 animations:^{
            // 修改尺寸
            self.presentView.frame = superView.bounds;
        }];
    }  completion:^(BOOL finished) {
        // 修改控制视图的约束
        [self updateControlViewConstraint];
    }];
}

- (void)updateControlViewConstraint
{
    // 当屏幕旋转后，屏幕的长宽也发生了变化，现在长的值变为了原来的宽的值
    if (self.isFullScreen)
    {
        CGFloat width = self.presentView.bounds.size.width;
        CGFloat height = self.presentView.bounds.size.height;
        self.controlView.frame = CGRectMake(0, height - 40, width, 40);
    }
    else
    {
        CGFloat width = SCREEN_WIDTH;
        CGFloat height = SCREEN_WIDTH / 7 * 4;
        self.controlView.frame = CGRectMake(0, height - 40, width, 40);
    }
    
    // 如果不执行下面的两个方法， 上面的设置无效
    // 标记更新约束
    [self.controlView setNeedsUpdateConstraints];
    // 更新约束
    [self.controlView updateConstraintsIfNeeded];
}

// 记录用户拖动的状态，当用户拖动的时候不更新播放进度
- (void)sliderStartDraggingAction:(UISlider *)slider
{
    self.isDragging = YES;
}

// 用户拖动结束，跳转播放进度
- (void)seekToPlayerTimeAction:(UISlider *)slider
{
    CGFloat duration = CMTimeGetSeconds(self.playerItem.duration);
    
    // 没准备好播放，不允许跳转播放进度
    if (duration == 0) {return;}
    CGFloat seekTime = duration *slider.value;
    [self.player seekToTime:CMTimeMakeWithSeconds(seekTime, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        if (finished)
        {
            [self play];
            self.isDragging = NO;
        }
        
    }];
}

- (void)initUI
{
    self.view.backgroundColor = [UIColor whiteColor];
}

- (FHControlView *)controlView
{
    if (!_controlView)
    {
        _controlView = [[FHControlView alloc] init];
        [_controlView.playBtn addTarget:self action:@selector(controlAction:) forControlEvents:UIControlEventTouchUpInside];
        [_controlView.fullScreanBtn addTarget:self action:@selector(fullScreanAction:) forControlEvents:UIControlEventTouchUpInside];
        [_controlView.playSlider addTarget:self action:@selector(sliderStartDraggingAction:) forControlEvents:UIControlEventTouchDragInside];
        [_controlView.playSlider addTarget:self action:@selector(seekToPlayerTimeAction:) forControlEvents:UIControlEventValueChanged];

    }
    
    return _controlView;
}

- (NSString *)videoPath
{
    if (!_videoPath)
    {
        NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
        _videoPath = [document stringByAppendingPathComponent:@"保存数据.mp4"];
    }
    
    return _videoPath;
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    if (self.isFullScreen)
    {
        return UIStatusBarStyleLightContent;
    }
    
    return UIStatusBarStyleDefault;
}


// 是否支持屏幕旋转
// if yes, [UIApplication sharedApplication].statusBarOrientation = deviceOrientation; 设置无效；
// if yes, - (UIInterfaceOrientationMask)supportedInterfaceOrientations；支持的屏幕方向一定要和Deployment Info -> Device Orientation 一致， 否则会报  Terminating app due to uncaught exception 'UIApplicationInvalidInterfaceOrientation', reason: 'Supported orientations has no common orientation with the application, and [FHNavigationController shouldAutorotate] is returning YES'
- (BOOL)shouldAutorotate
{
    return NO;
}


- (void)dealloc
{
    [self stop];
    NSLog(@"%@ dealloc",[self class]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    NSLog(@"didReceiveMemoryWarning");
}

@end
