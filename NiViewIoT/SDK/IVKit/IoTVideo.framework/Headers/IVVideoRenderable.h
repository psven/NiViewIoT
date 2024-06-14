//
//  IVVideoRenderable.h
//  IoTVideo
//
//  Created by JonorZhang on 2020/7/27.
//  Copyright © 2020 Tencentcs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IVAVDefine.h"

NS_ASSUME_NONNULL_BEGIN

/// 视频画面缩放模式
typedef NS_ENUM(NSInteger, IVVideoScalingMode) {
    /// 等比例缩放，直至画面内容恰好能完全显示，其余部分是透明的
    IVVideoScalingModeAspectFit,
    /// 等比例缩放，直至画面内容恰好填满视频窗口，部分内容可能会被剪裁
    IVVideoScalingModeAspectFill,
    /// 非等比拉伸填充视频窗口，画面可能会变形
    IVVideoScalingModeFill,
};

// 视频渲染数据源
@protocol IVVideoRenderDataSource <NSObject>

/// 获取YUV视频数据
/// @param[in,out] vframe 用于接收视频帧数据
/// @note vframe入参时 `vframe->data[i]`不可为NULL（由开发者malloc和free），vframe->linesize[i]`不可为0；
/// @return [YES]成功，[NO]失败
- (BOOL)getVideoFrame:(IVVideoFrame *)vframe;

@end

/// 视频渲染器协议
@protocol IVVideoRenderable <NSObject>

/// 视频画面
@property (nonatomic, strong, readonly) UIView *videoView;

/// 鱼眼畸变矫正系数，-1.0 ～ 1.0， 默认0.0
/// 当 < 0 为枕形畸变，当 > 0 为桶形畸变
@property (nonatomic, assign) float distortionFactor;

/// 画面缩放模式, 默认`IVVideoScalingModeAspectFit`
@property (nonatomic, assign) IVVideoScalingMode scalingMode;

/// 是否正在运行
@property (nonatomic, assign, readonly) BOOL isRendering;


/// 视频画面截图
/// @param completionHandler 完成回调
- (void)takeScreenshot:(void(^)(UIImage * _Nullable image))completionHandler;

/// 开始运行
/// @param avheader 流媒体信息头
/// @param channel 通道ID
/// @param dataSource 数据源
- (BOOL)startRenderingWithAVHeader:(IVAVHeader)avheader channel:(uint32_t)channel dataSource:(id<IVVideoRenderDataSource>)dataSource;

/// 停止运行
- (void)stopRendering;

@end

NS_ASSUME_NONNULL_END
