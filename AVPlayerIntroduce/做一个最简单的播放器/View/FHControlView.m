//
//  FHControlView.m
//  AVPlayerIntroduce
//
//  Created by fuhang on 2018/8/1.
//  Copyright © 2018年 wechat. All rights reserved.
//

#import "FHControlView.h"

@implementation FHControlView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    self = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] lastObject];
    if (self) {
        self.frame = frame;
    }
    
    return self;
}

@end
