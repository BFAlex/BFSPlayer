//
//  BFSPlayerController.m
//  BFSPlayer
//
//  Created by 刘玲 on 2018/12/25.
//  Copyright © 2018年 GKD. All rights reserved.
//

#import "BFSPlayerController.h"
#import "FFMPegPlayer.h"

@interface BFSPlayerController () {
    FFMPegPlayer    *_player;
}
@property (weak, nonatomic) IBOutlet UIView *playerView;

@end

@implementation BFSPlayerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self testFFMPeg];
}

#pragma mark - Action

- (IBAction)actionPlayBtn:(UIButton *)sender {
    
    [_player seekTime:0.0];
    [NSTimer scheduledTimerWithTimeInterval:1 / _player.fps target:self selector:@selector(playNextFrame:) userInfo:nil repeats:YES];
}

#pragma mark - Test

- (void)testFFMPeg {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test_video.mp4" ofType:nil];
    _player = [FFMPegPlayer playerForPath:path andPlayView:self.playerView];
    NSLog(@"%@", _player);
}

- (void)playNextFrame:(NSTimer *)timer {
    
    [_player displayNextFrame:timer];
}

@end
