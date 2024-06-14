//
//  IVAudioConvert.h
//  IoTVideo
//
//  Created by JonorZhang on 2021/3/30.
//  Copyright © 2021 Tencentcs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface IVAudioConvert : NSObject

/// 倍速 0.5～2.0, 默认1.0
@property (nonatomic, assign) float tempo;
/// 音调 0.5～2.0, 默认1.0
@property (nonatomic, assign) float pitch;
/// 速率 0.5～2.0, 默认1.0
@property (nonatomic, assign) float rate;


/// 配置变音器，填写原始PCM参数
/// @param sampleRate 采样率
/// @param samplesPerFrame 每帧长度
/// @param bitWidth 采样点位宽
/// @param channels 通道数
/// @param link_chn_id 通道ID，不关心则填0
- (void)configWithSampleRate:(uint32_t)sampleRate samplesPerFrame:(uint32_t)samplesPerFrame bitWidth:(uint8_t)bitWidth channels:(uint8_t)channels link_chn_id:(uint32_t)link_chn_id;

/// 输入原始PCM数据
/// @param samples 原PCM
/// @param nBytes 字节数
- (void)putSamples:(const uint8_t *)samples nBytes:(uint32_t)nBytes;

/// 获取变音后PCM数据
/// @param outBuffer 接收缓冲区
/// @param maxBytes 缓冲区最大字节数
/// @return 获取到的实际字节数
- (uint32_t)receiveSamples:(uint8_t *)outBuffer maxBytes:(uint32_t)maxBytes;

/// 微秒/字节
@property (nonatomic, assign, readonly) float usecPerByte;

/// 字节/帧
@property (nonatomic, assign, readonly) float nBytesPerFame;

@end

NS_ASSUME_NONNULL_END
