//
//  ViewController.m
//  BFSPlayer(ffmpeg)
//
//  Created by 刘玲 on 2018/12/21.
//  Copyright © 2018年 GKD. All rights reserved.
//

#import "ViewController.h"
#import "BFSPlayer.h"

@interface ViewController () {
    float   _lastFrameTime;
    UIImageView *_playerImageView;
}
@property (weak, nonatomic) IBOutlet UIView *playerBG;

@property (nonatomic, strong) BFSPlayer *player;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initBase];
}

#pragma mark -

- (void)initBase {
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:self.playerBG.bounds];
    [self.playerBG addSubview:imgView];
    _playerImageView = imgView;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test_video" ofType:@"mp4"];
    self.player = [BFSPlayer playerForPath:path andPlayView:self.playerBG];
}

- (void)displayNextFrame:(NSTimer *)timer {
    
    NSTimeInterval startTime = [NSDate timeIntervalSinceReferenceDate];
//    NSLog(@"cur frame time: %@", [self dealTime:self.player.currentTime]);
    if (![self.player stepFrame]) {
        [timer invalidate];
        return;
    }
    _playerImageView.image = self.player.currentImage;
    
}

- (NSString *)dealTime:(double)time {
    
    int sec, min, hour;
    
    sec = time;
    hour = sec / 3600;
    min = (sec % 3600) / 60;
    sec = sec % 60;
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d", hour, min, sec];
}

#pragma mark - Action

- (IBAction)actionPlayBtn:(UIButton *)sender {
    
    _lastFrameTime = -1;
    [self.player seekTime:0.0];
    
    [NSTimer scheduledTimerWithTimeInterval:1 / self.player.fps
                                     target:self
                                   selector:@selector(displayNextFrame:)
                                   userInfo:nil
                                    repeats:YES];
}


@end
