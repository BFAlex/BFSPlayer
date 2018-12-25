//
//  FFMPegPlayer.h
//  BFSPlayer
//
//  Created by 刘玲 on 2018/12/25.
//  Copyright © 2018年 GKD. All rights reserved.
//

#import "BFSBasePlayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface FFMPegPlayer : BFSBasePlayer

@property (nonatomic, assign, readonly) double fps;

- (void)seekTime:(double)time;
- (void)displayNextFrame:(NSTimer *)timer;

@end

NS_ASSUME_NONNULL_END
