//
//  IVPlayer.h
//  IoTVideo
//
//  Created by JonorZhang on 2019/11/13.
//  Copyright © 2019 Tencentcs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IVAVDefine.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#import "IVAVUtils.h"

#import "IVMessageMgr.h"
#import "IVConnection.h"

NS_ASSUME_NONNULL_BEGIN


/// 设置结果回调。error为nil表示成功， 否则失败。
typedef void (^IVSettingCallback)(NSError *_Nullable error);

/// 属性设置结果回调
/// @note (1）未连接:  播放器保存新值后直接回调设置成功，待发起连接时携带新值给到设备；
///       (2）已连接：播放器先发送新值给到设备，待设备响应后回调设置结果，若设置成功才保存新值；
typedef IVSettingCallback IVPropertySettingCallback;

/// 指令控制结果回调
/// @note (1）未连接:  直接回调设置失败；
///       (2）已连接：播放器先发送指令给到设备，待设备响应后回调设置结果；
typedef IVSettingCallback IVCommandSettingCallback;


@class IVPlayer;

#pragma mark - 播放器代理

/// 播放器代理
@protocol IVPlayerDelegate <IVConnectionDelegate>

@optional

/// 播放器状态回调
/// @param player 播放器实例
/// @param status 状态值
- (void)player:(IVPlayer *)player didUpdateStatus:(IVPlayerStatus)status;

/// 播放时间回调
/// @param player 播放器实例
/// @param PTS 时间戳
- (void)player:(IVPlayer *)player didUpdatePTS:(NSTimeInterval)PTS;

/// SD卡回放文件即将播放
/// @param player 播放器实例
/// @param fileTime 即将播放的文件（文件开始时间）
- (void)player:(IVPlayer *)player willBeginOfFile:(NSTimeInterval)fileTime;

/// SD卡回放文件播放结束
/// @param player 播放器实例
/// @param fileTime 播放结束的文件（文件开始时间）
/// @param error  nil：正常完成， 非nil：播放错误
- (void)player:(IVPlayer *)player didEndOfFile:(NSTimeInterval)fileTime error:(nullable NSError *)error;

/// 观看人数变更
/// @param player 播放器实例
/// @param viewerNum 观看人数
- (void)player:(IVPlayer *)player didUpdateViewerNum:(NSInteger)viewerNum ;

/// 对讲人数变更
/// @param player 播放器实例
/// @param talkerNum 与当前设备对讲的人数
- (void)player:(IVPlayer *)player didUpdateTalkerNum:(NSInteger)talkerNum;

/// 播放错误回调
/// 播放器捕获到的一些错误（不一定会导致播放中断），用于辅助开发者定位和发现问题，不要在此处stop()
/// @param player 播放器实例
/// @param error 错误实例, 见 @c `IVPlayerError`
- (void)player:(IVPlayer *)player didReceiveError:(NSError *)error;

/// 音视频头信息回调
/// @param player  播放器实例
/// @param avHeader 音视频头信息
- (void)player:(IVPlayer *)player didReceiveAVHeader:(IVAVHeader)avHeader;

#pragma mark - Deprecated

/// SD卡回放文件播放结束（已过期）
/// @param player 播放器实例
/// @param startTime 当前播放结束的文件的开始时间
/// @deprecated Use `-player:didEndOfFile:error:` instead
- (void)player:(IVPlayer *)player didFinishPlaybackFile:(NSTimeInterval)startTime API_DEPRECATED("Use -player:didEndOfFile:error:", ios(2.0,9.0));

/// 观众人数变更（已过期）
/// @param player 播放器实例
/// @param audience 观众人数
/// @deprecated Use `-player:didUpdateViewerNum:` instead
- (void)player:(IVPlayer *)player didUpdateAudience:(NSInteger)audience API_DEPRECATED("Use -player:didUpdateViewerNum: instead", ios(2.0,9.0));
@end

#pragma mark - 对讲协议

/// 播放器对讲协议
@protocol IVPlayerTalkable <IVAudioCaptureDelegate>

/// 对讲和视频通话时APP端使用的流媒体信息头, 由对应采集器和编码器参数组合而成, 建立连接时会发送给设备。
@property (nonatomic, assign, readonly) IVAVHeader encHeader;

/// 音频采集器, 默认为 `IVAudioCapture`
@property (nonatomic, strong, readwrite) id<IVAudioCapturable> audioCapture;

/// 音频编码器, 默认为 `IVAudioEncoder`
@property (nonatomic, strong, readwrite) id<IVAudioEncodable> audioEncoder;

/// 当前与设备对讲的客户端数量
@property (nonatomic, assign, readonly) NSUInteger talkerNum;

/// 是否正在对讲
@property (nonatomic, assign, readonly) BOOL isTalking;

/// 开启对讲
- (void)startTalking;

/// 开启对讲, 该方法默认会打开手机麦克风
/// completionHandler回调可能包含设备端应用层发送自定义errorCode(不一定表示开启失败，也可能是一些权限警告、人数限制)
/// 因此APP应用层应判断此errorCode，如果是表示开启失败请stopTalking之后才能再尝试startTalking
- (void)startTalking:(nullable IVCommandSettingCallback)completionHandler;

/// 结束对讲
- (void)stopTalking;

/// 结束对讲
- (void)stopTalking:(nullable IVCommandSettingCallback)completionHandler;

@end

#pragma mark - 双向视频协议

/// 播放器双向视频协议
@protocol IVPlayerVideoable <IVVideoCaptureDelegate>

/// 对讲和视频通话时APP端使用的流媒体信息头, 由对应采集器和编码器参数组合而成, 建立连接时会发送给设备。
@property (nonatomic, assign, readonly) IVAVHeader encHeader;

/// 视频采集器, 默认为 `IVVideoCapture`
@property (nonatomic, strong, readwrite) id<IVVideoCapturable> videoCapture;

/// 视频编码器, 默认为 `IVVideoEncoder`
@property (nonatomic, strong, readwrite) id<IVVideoEncodable> videoEncoder;

/// 摄像头预览图层
@property (nonatomic, strong, readonly) CALayer *previewLayer;

/// 镜头位置
@property (nonatomic, assign, readwrite) IVCameraPosition cameraPosition;

/// 是否正在开启摄像头
@property (nonatomic, assign, readonly) BOOL isCameraOpening;

/// 视频帧率，默认16
@property (nonatomic, assign, readwrite) int frameRate;

/// 开启双向视频
- (void)openCamera;

/// 开启双向视频，该方法默认会打开手机摄像头
/// completionHandler回调可能包含设备端应用层发送自定义errorCode(不一定表示开启失败，也可能是一些权限警告、人数限制)
/// 因此APP应用层应判断此errorCode，如果是表示开启失败请closeCamera之后才能再尝试openCamera
- (void)openCamera:(nullable IVCommandSettingCallback)completionHandler;

/// 结束双向视频
- (void)closeCamera;

/// 结束双向视频
- (void)closeCamera:(nullable IVCommandSettingCallback)completionHandler;

/// 切换手机端摄像头
- (void)switchCamera;

@end

#pragma mark - 核心播放器

/// 核心播放器
/// @note IVPlayer为抽象基类，请勿直接实例化，应使用其派生类:IVLivePlayer、IVPlaybackPlayer和IVMonitorPlayer
@interface IVPlayer : IVConnection <IVAudioRenderDataSource, IVVideoRenderDataSource>

/// 播放器代理
@property (nonatomic, weak, nullable) id<IVPlayerDelegate> delegate;

/// 接收到设备端端的流媒体信息头
@property (nonatomic, assign, readonly) IVAVHeader avheader;

/// 视频画面
@property (nonatomic, strong, readonly) UIView *videoView;

/// 当前设备观众人数 @c `-[IVPlayerDelegate player: didUpdateAudience:]`
@property (nonatomic, assign, readonly) NSUInteger audience;

/// 播放器状态
@property (nonatomic, assign, readonly) IVPlayerStatus status;

/// 播放器是否正在播放，即 self.status == IVPlayerStatusPlaying
@property (nonatomic, assign, readonly) BOOL isPlaying;

/// 当前播放时间戳（秒）
@property (nonatomic, assign, readonly) NSTimeInterval pts;

/// 视频清晰度，默认`IVVideoDefinitionHigh`,  setter方法等于`-[setDefinition:xx completionHandler:nil]`
@property (nonatomic, assign) IVVideoDefinition definition;

/// 设置视频清晰度
- (void)setDefinition:(IVVideoDefinition)definition completionHandler:(nullable IVPropertySettingCallback)completionHandler;

/// 静音，  默认NO（即允许播放声音）
@property (nonatomic, assign, readwrite) BOOL mute;

/// 免提， 默认YES, 有外设时无效
/// @li YES 没有外设时外放声音
/// @li NO  没有外设时听筒处播放声音
@property (nonatomic, assign, readwrite) BOOL handsFree;

/// 预连接(可选)
/// 设备会发送流媒体信息头，但不会发送音视频数据,
/// @note 已废弃，内部直接return
- (void)prepare API_DEPRECATED("No longer supported", ios(2.0, 9.0));

/// 开始播放
/// @note 设备会发送流媒体信息头，接着发送音视频数据
- (void)play;

/// 停止播放
/// @note 该操作APP将与设备断开连接
- (void)stop;

/// 截图
/// @param completionHandler 截图回调
- (void)takeScreenshot:(void(^)(UIImage * _Nullable image))completionHandler;

/// 是否正在录像
@property (nonatomic, assign, readonly) BOOL isRecording;

/// 开始录像
/// @param savePath 录像文件路径
/// @param completionHandler 完成回调
- (void)startRecording:(NSString *)savePath completionHandler:(void(^)(NSString * _Nullable savePath, NSError * _Nullable error))completionHandler;

/// 开始录像, 带时长回调
/// @param savePath 录像文件路径
/// @param durationCallback 时长回调
/// @param completionHandler 完成回调
- (void)startRecording:(NSString *)savePath durationCallback:(void(^)(NSTimeInterval duration))durationCallback completionHandler:(void(^)(NSString * _Nullable savePath, NSError * _Nullable error))completionHandler;

/// 停止录像
- (void)stopRecording;

/// 发送自定义数据
/// 与设备建立连接后才可发送，适用于较大数据传输、实时性要求较高的场景，如多媒体数据传输。
/// 接收到设备端发来的数据见`-[IVConnectionDelegate connection:didReceiveData:]`
/// @param data 要发送的数据，data.length不能超过`MAX_PKG_BYTES`
/// @return 发送是否成功
- (BOOL)sendData:(NSData *)data;

/// 发送自定义数据
/// @param data 要发送的数据，data.length不能超过`MAX_PKG_BYTES`
/// @param sequence 是否串行发送
/// @param callback 完成回调。callback非nil则通过callback回调；callback为nil则通过代理回调；
- (BOOL)sendData:(nullable NSData *)data sequence:(BOOL)sequence multiCallback:(nullable IVMsgMultiRspCallback)callback;


#pragma mark - 解码器/渲染器/录制器

/// 音频解码器, 默认为 `IVAudioDecoder`
@property (nonatomic, strong, readwrite) id<IVAudioDecodable> audioDecoder;

/// 音频渲染器, 默认为 `IVAudioRender`
@property (nonatomic, strong, readwrite) id<IVAudioRenderable> audioRender;

/// 视频解码器, 默认为 `IVVideoDecoder`
@property (nonatomic, strong, readwrite) id<IVVideoDecodable> videoDecoder;

/// 视频渲染器, 默认为`IVVideoRender`
@property (nonatomic, strong, readwrite) id<IVVideoRenderable> videoRender;

/// 音视频录制器, 默认为`IVAVRecorder`
@property (nonatomic, strong, readwrite) id<IVAVRecordable> avRecorder;


#pragma mark - DEBUG

/// 播放器调试模式，默认`NO`。若设为`YES`则在编/解码时将音视频数据写入Document根目录。说明文档: Docs/抓取音视频流方法.md
/// @note ⚠️开启可能会导致卡顿。
/// @code
///  播放相关音频文件:
///  au_rcv_in   音频 接收器 输入流
///  au_dec_in   音频 解码器 输入流
///  au_dec_out  音频 解码器 输出流
///
///  播放相关视频文件:
///  vi_rcv_in   视频 接收器 输入流
///  vi_dec_in   视频 解码器 输入流
///
///  对讲相关音频文件:
///  au_fill_in  音频 采集器 输出流
///  au_enc_in   音频 编码器 输入流
///  au_enc_out  音频 编码器 输出流
///
///  双向视频通话相关文件:
///  vi_enc_out  视频 编码器 输出流
/// @endcode
@property (class, nonatomic, assign, readwrite) BOOL debugMode;

@end

NS_ASSUME_NONNULL_END
