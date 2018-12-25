//
//  BFSBasePlayer.m
//  BFSPlayer
//
//  Created by 刘玲 on 2018/12/25.
//  Copyright © 2018年 GKD. All rights reserved.
//

#import "BFSBasePlayer.h"

@interface BFSBasePlayer ()

@end

@implementation BFSBasePlayer

+ (instancetype)playerForPath:(NSString *)path andPlayView:(UIView *)playView {
    
    if (path.length < 1 || !playView) {
        return nil;
    }
    
    BFSBasePlayer *player = [[BFSBasePlayer alloc] initWithPath:path andPlayView:playView];
//    if (player) {
//        player.playPath = [path copy];
//        player.playView = playView;
//    }
    
    
    return player;
}

- (instancetype)initWithPath:(NSString *)path andPlayView:(UIView *)playView {
    
    if (self = [super init]) {
        self.playPath = [path copy];
        self.playView = playView;
    }
    
    return self;
}

@end
