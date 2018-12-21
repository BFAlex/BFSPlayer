//
//  BFSPlayer.m
//  BFSPlayer(ffmpeg)
//
//  Created by 刘玲 on 2018/12/21.
//  Copyright © 2018年 GKD. All rights reserved.
//

#import "BFSPlayer.h"

#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libswscale/swscale.h>

@interface BFSPlayer () {
    
    AVFormatContext     *_formatCtx;
    AVStream            *_stream;
    AVPacket            *_packet;
    AVPicture           *_picture;
    AVCodecContext      *_codecCtx;
    AVFrame             *_frame;
    
    BOOL                _isReleaseResource;
    int                 _videoStream;
//    double              _fps;
    int                 _videoWidth;
    int                 _videoHeight;
}

@end

@implementation BFSPlayer

#pragma mark - Property

- (double)currentTime {
    
    AVRational timeBase = _formatCtx->streams[_videoStream]->time_base;
    return _packet->pts * (double)timeBase.num / timeBase.den;
}

- (UIImage *)currentImage {
    if (!_frame->data[0]) {
        return nil;
    }
    
    return [self imageFromeAVPicture];
}

#pragma mark -

+ (instancetype)playerForPath:(NSString *)path andPlayView:(UIView *)playView {
    
    BFSPlayer *player = [[BFSPlayer alloc] init];
    if (player) {
        // 为所欲为
        if (![player configBasePlayerResource:[path UTF8String]]) {
            return nil;
        }
    }
    
    return player;
}

- (BOOL)configBasePlayerResource:(const char *)filePath {
    
    _isReleaseResource = NO;
    
    // 注册控件
    avcodec_register_all();
    av_register_all();
    avformat_network_init();
    
    // open video file
    if (avformat_open_input(&_formatCtx, filePath, NULL, NULL) < 0) {
        NSLog(@"fail to open video file");
        goto configError;
    }
    // check data stream
    if (avformat_find_stream_info(_formatCtx, NULL) < 0) {
        NSLog(@"fail to check data stream");
        goto configError;
    }
    // find the first video stream
    AVCodec *pCodec;
    _videoStream = av_find_best_stream(_formatCtx, AVMEDIA_TYPE_VIDEO, -1, -1, &pCodec, 0);
    if (_videoStream < 0) {
        NSLog(@"fail to find the first video stream");
        goto configError;
    }
    
    _stream = _formatCtx->streams[_videoStream];
    _codecCtx = _stream->codec;
    
    // 帧率
    if (_stream->avg_frame_rate.den && _stream->avg_frame_rate.num) {
        _fps = av_q2d(_stream->avg_frame_rate);
    } else {
        _fps = 30;
    }
    
    // find stream codec
    pCodec = avcodec_find_decoder(_codecCtx->codec_id);
    if (pCodec == NULL) {
        NSLog(@"fail to find stream codec");
        goto configError;
    }
    
    // open stream codec
    if (avcodec_open2(_codecCtx, pCodec, NULL) < 0) {
        NSLog(@"fail to open stream codec");
        goto configError;
    }
    
    // video frame
    _frame = av_frame_alloc();
    _videoWidth = _codecCtx->width;
    _videoHeight = _codecCtx->height;
    
    return YES;
configError:
    return false;
}

- (void)seekTime:(double)seconds {
    
    AVRational timeBase = _formatCtx->streams[_videoStream]->time_base;
    int64_t targetFrame = (int64_t)((double)timeBase.den / timeBase.num * seconds);
    avformat_seek_file(_formatCtx, _videoStream, 0, targetFrame, targetFrame, AVSEEK_FLAG_FRAME);
}

- (BOOL)stepFrame {
    
    int frameFinished = 0;
    while (!frameFinished && av_read_frame(_formatCtx, &_packet) >= 0) {
        if (_packet->stream_index == _videoStream) {
            avcodec_decode_video2(_codecCtx, _frame, &frameFinished, &_packet);
        }
    }
    if (frameFinished == 0 && _isReleaseResource == NO) {
        [self releaseResources];
    }
    
    return frameFinished != 0;
}

- (void)releaseResources {
    
    _isReleaseResource = YES;
    avpicture_free(&_picture);
    av_packet_free(&_packet);
    av_free(_frame);
    if (_codecCtx) {
        avcodec_close(_codecCtx);
    }
    if (_formatCtx) {
        avformat_close_input(&_formatCtx);
    }
    avformat_network_deinit();
}

- (UIImage *)imageFromeAVPicture {
    
    avpicture_free(&_picture);
    avpicture_alloc(&_picture, AV_PIX_FMT_RGB24, _videoWidth, _videoHeight);
    struct SwsContext *imgConvertCtx = sws_getContext(_frame->width,
                                                      _frame->height,
                                                      AV_PIX_FMT_YUV420P,
                                                      _videoWidth,
                                                      _videoHeight,
                                                      AV_PIX_FMT_RGB24,
                                                      SWS_FAST_BILINEAR,
                                                      NULL,
                                                      NULL,
                                                      NULL);
    if (imgConvertCtx == nil) {
        return nil;
    }
    
    sws_scale(imgConvertCtx, _frame->data, _frame->linesize, 0, _frame->height, _picture->data, _picture->linesize);
    sws_freeContext(imgConvertCtx);
    
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CFDataRef data = CFDataCreate(kCFAllocatorDefault, _picture->data[0], _picture->linesize[0] * _videoHeight);
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(data);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef cgImage = CGImageCreate(_videoWidth, _videoHeight, 8, 24, _picture->linesize[0], colorSpace, bitmapInfo, provider, NULL, NO, kCGRenderingIntentDefault);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    CGColorSpaceRelease(colorSpace);
    CGDataProviderRelease(provider);
    CFRelease(data);
    
    return image;
}

@end
