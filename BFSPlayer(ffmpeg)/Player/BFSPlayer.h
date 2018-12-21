//
//  BFSPlayer.h
//  BFSPlayer(ffmpeg)
//
//  Created by 刘玲 on 2018/12/21.
//  Copyright © 2018年 GKD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BFSPlayer : NSObject

@property (nonatomic, assign) double fps;
@property (nonatomic, assign, readonly) double currentTime;
@property (nonatomic, strong, readonly) UIImage *currentImage;

+ (instancetype)playerForPath:(NSString * _Nonnull)path andPlayView:(UIView *)playView;

- (void)seekTime:(double)seconds;
- (BOOL)stepFrame;

@end

NS_ASSUME_NONNULL_END
