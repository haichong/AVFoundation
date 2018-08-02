//
//  FHControlView.h
//  AVPlayerIntroduce
//
//  Created by fuhang on 2018/8/1.
//  Copyright © 2018年 wechat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FHControlView : UIView


@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UILabel *playTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *loadedProgress;
@property (weak, nonatomic) IBOutlet UISlider *playSlider;


@end
