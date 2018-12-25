//
//  BFSBasePlayer.h
//  BFSPlayer
//
//  Created by 刘玲 on 2018/12/25.
//  Copyright © 2018年 GKD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libswscale/swscale.h>

NS_ASSUME_NONNULL_BEGIN

@interface BFSBasePlayer : NSObject

@property (nonatomic, weak) UIView *playView;
@property (nonatomic, copy) NSString *playPath;

+ (instancetype)playerForPath:(NSString *)path andPlayView:(UIView *)playView;
- (instancetype)initWithPath:(NSString *)path andPlayView:(UIView *)playView;

@end

NS_ASSUME_NONNULL_END
