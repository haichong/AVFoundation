//
//  FHSamplePlayerViewController.h
//  AVPlayerIntroduce
//
//  Created by fuhang on 2018/7/31.
//  Copyright © 2018年 wechat. All rights reserved.
//

/// 这个connenction的功能是把task缓存到本地的临时数据根据播放器需要的 offset和length去取数据并返回给播放器
/// 如果视频文件比较小，就没有必要存到本地，直接用一个变量存储即可
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class VideoRequestTask;

@protocol TBloaderURLConnectionDelegate <NSObject>

- (void)didFinishLoadingWithTask:(VideoRequestTask *)task;
- (void)didFailLoadingWithTask:(VideoRequestTask *)task WithError:(NSInteger )errorCode;

@end

@interface LoaderURLConnection : NSURLConnection <AVAssetResourceLoaderDelegate>

@property (nonatomic, strong) VideoRequestTask *task;
@property (nonatomic, weak  ) id<TBloaderURLConnectionDelegate> delegate;
- (NSURL *)getSchemeVideoURL:(NSURL *)url;

@end
