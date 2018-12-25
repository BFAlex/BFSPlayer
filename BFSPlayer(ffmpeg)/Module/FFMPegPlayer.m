//
//  FFMPegPlayer.m
//  BFSPlayer
//
//  Created by 刘玲 on 2018/12/25.
//  Copyright © 2018年 GKD. All rights reserved.
//

#import "FFMPegPlayer.h"

@interface FFMPegPlayer () {
    
    UIImageView         *_imageView;
    
    AVFormatContext     *_formatCtx;
    AVStream            *_stream;
    AVCodecContext      *_codecCtx;
    AVPacket            _packet;
    AVFrame             *_frame;
    AVPicture           _picture;
    
    int     _videoStream;
    double  _fps;
    int     _videoWidth;
    int     _videoHeight;
    BOOL    _isReleaseResources;
}

@end

@implementation FFMPegPlayer

#pragma mark - API

+ (instancetype)playerForPath:(NSString *)path andPlayView:(UIView *)playView {
    
    FFMPegPlayer *player = [[FFMPegPlayer alloc] initWithPath:path andPlayView:playView];
    if (player) {
        if ([player initResources]) {
            [player setupUI];
        } else {
            return nil;
        }
        
    }
    
    return player;
}

- (void)seekTime:(double)time {
    
    AVRational timeBase = _formatCtx->streams[_videoStream]->time_base;
    int64_t targetFrame = (int64_t)((double)timeBase.den/timeBase.num);
    avformat_seek_file(_formatCtx, _videoStream, 0, targetFrame, targetFrame, AVSEEK_FLAG_FRAME);
    avcodec_flush_buffers(_codecCtx);    
}

- (void)displayNextFrame:(NSTimer *)timer {
    
//    NSTimeInterval startTime = [NSDate timeIntervalSinceReferenceDate];
    if (![self stepFrame]) {
        [timer invalidate];
        return;
    }
    // show image;
    _imageView.image = [self curFrameImage];
}

- (UIImage *)curFrameImage {
    
    if (!_frame->data[0]) {
        return nil;
    }
    
    avpicture_free(&_picture);
    avpicture_alloc(&_picture, AV_PIX_FMT_RGB24, _videoWidth, _videoHeight);
    struct SwsContext *imgConvertCtx = sws_getContext(_frame->width, _frame->height, AV_PIX_FMT_YUV420P, _videoWidth, _videoHeight, AV_PIX_FMT_RGB24, SWS_FAST_BILINEAR, NULL, NULL, NULL);
    if (imgConvertCtx == nil) {
        return nil;
    }
    
    sws_scale(imgConvertCtx, _frame->data, _frame->linesize, 0, _frame->height, _picture.data, _picture.linesize);
    sws_freeContext(imgConvertCtx);
    
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CFDataRef data = CFDataCreate(kCFAllocatorDefault, _picture.data[0], _picture.linesize[0] * _videoHeight);
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(data);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef cgImage = CGImageCreate(_videoWidth, _videoHeight, 8, 24, _picture.linesize[0], colorSpace, bitmapInfo, provider, NULL, NO, kCGRenderingIntentDefault);
    
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    CGColorSpaceRelease(colorSpace);
    CGDataProviderRelease(provider);
    CFRelease(data);
    
    return image;
}

- (BOOL)stepFrame {
    
    int frameFinished = 0;
    int readResult;
    while (!frameFinished && (readResult = av_read_frame(_formatCtx, &_packet)) >= 0) {
        if (_packet.stream_index == _videoStream) {
            avcodec_decode_video2(_codecCtx, _frame, &frameFinished, &_packet);
        }
    }
    if (frameFinished == 0 && _isReleaseResources == NO) {
        [self releaseResources];
    }
    
    return frameFinished;
}

- (void)releaseResources {
    NSLog(@"*** releaseResources ***");
    _isReleaseResources = YES;
    avpicture_free(&_picture);
    av_packet_unref(&_packet);
    av_free(_frame);
    if (_codecCtx) {
        avcodec_close(_codecCtx);
    }
    if (_formatCtx) {
        avformat_close_input(&_formatCtx);
    }
    avformat_network_deinit();
}

- (NSString *)description {
    
    NSString *desc = [NSString stringWithFormat:@"player = {\npath = %@\n}", self.playPath];
    
    return desc;
}

#pragma mark - Private

- (BOOL)initResources {
    
    _isReleaseResources = NO;
    
    const char *rPath = [self.playPath UTF8String];
    
    av_register_all();
    avcodec_register_all();
    avformat_network_init();
    
    if (avformat_open_input(&_formatCtx, rPath, NULL, NULL) < 0) {
        NSLog(@"打开文件失败");
        goto initError;
    }
    
    if (avformat_find_stream_info(_formatCtx, NULL) < 0) {
        NSLog(@"2222->F");
        goto initError;
    }
    
    AVCodec *pDecoder;
    if ((_videoStream = av_find_best_stream(_formatCtx, AVMEDIA_TYPE_VIDEO, -1, -1, &pDecoder, 0)) < 0) {
        NSLog(@"3333->F");
        goto initError;
    }
    
    _stream = _formatCtx->streams[_videoStream];
    _codecCtx = _stream->codec;
    
    if (_stream->avg_frame_rate.den && _stream->avg_frame_rate.num) {
        _fps = av_q2d(_stream->avg_frame_rate);
    } else {
        _fps = 30;
    }
    
    pDecoder = avcodec_find_decoder(_codecCtx->codec_id);
    if (!pDecoder) {
        NSLog(@"4444->F");
        goto initError;
    }
    
    if (avcodec_open2(_codecCtx, pDecoder, NULL) < 0) {
        NSLog(@"666->F");
        goto initError;
    }
    
    _frame = av_frame_alloc();
//    _videoWidth = _codecCtx->width;
//    _videoHeight = _codecCtx->height;
    _videoWidth = self.playView.bounds.size.width;
    _videoHeight = self.playView.bounds.size.height;
    
    
    return true;
initError:
    return false;
}
- (void)setupUI {
    
    _imageView = [[UIImageView alloc] initWithFrame:self.playView.bounds];
    [self.playView addSubview:_imageView];
}

@end
