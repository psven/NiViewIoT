//
//  IVAVWorkflow.h
//  IoTVideo
//
//  Created by JonorZhang on 2022/3/11.
//  Copyright © 2022 Tencentcs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 目前，SDK内置了以下节点：
 - IVM3U8Parser
 - IVTSDownloader
 - IVAESDecrypt
 - IVDemuxer
 - IVVideoDecoder
 - IVVideoFilter
 - IVVideoEncoder
 - IVMuxer
 */
@class IVAVWorknode;

/**
 工作流（Workflow）由若干匹配输入输出的节点（Worknode）组成。
 开发者可根据需要自由组合或单独使用，以下给出音视频场景下常见的工作流。
 */
@interface IVAVWorkflow : NSObject

/// 工作流头结点
@property (nonatomic, strong, readonly) IVAVWorknode *headNode;

/// 工作流尾节点
@property (nonatomic, strong, readonly) IVAVWorknode *tailNode;

/// 输入文件url。若为云存文件断点续传时须保证文件时间范围一致（允许签名不一致）
@property (nonatomic, strong, readonly) NSString *url;

/// 输出文件路径，须含文件名和后缀， 如 "/var/mobile/...xxxx.mp4"，断点续传时须保证文件相对路径一致（允许沙盒唯一编码路径xxxxxx-xxxx-xxxx--xxxx-xxxxxxxxx不一致）
@property (nonatomic, strong, readonly) NSString *location;

/// 附加可选项, 默认nil，应在-start前设置好
/// 例如 @c `options = @{“t”: @(4*USEC_PER_SEC)}`，表示截取前4秒
/// @li -ss    <int64>  start time offset [us]，default to 0 (That is, the beginning of the file);
/// @li -t      <int64>  duration time [us], default to Total-Duration of file;
/// @li -fps  <int>  video frame per secend, default to 0(unspecified);
/// @li -vc   <IVVideoCodecType>  video encoder, default to 0(copy), or 1(h264) if '-vf' is specified, you can also set `-vc` forcibly;
/// @li -abr <string or Int64> the average bitrate of the video, the default is "mid" (WxHx3), you can also set an int64 value (e.g. 4000000);
///               "low-":  WxHx3/4
///               "low":   WxHx3/2
///               "mid":   WxHx3
///               "high":  WxHx3*2
///               "high+": WxHx3*4
/// @li -vf    <string> video filters, default to nil;  @see https://ffmpeg.org/ffmpeg-filters.html .  For example,
///               "movie=logo.png[logo]; [logo]colorkey=White:0.2:0.5 [alphawm]; [in][alphawm]overlay=20:20[out]"
///               "split [main][tmp]; [tmp] crop=iw:ih/2:0:0, vflip [flip]; [main][flip] overlay=0:H/2"
///               "vflip" or  "hflip"
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, id> *options;


/// 工作流状态
@property (readonly, getter=isExecuting) BOOL executing;
@property (readonly, getter=isFinished)  BOOL finished;
@property (readonly, getter=isCancelled) BOOL cancelled;
@property (readonly, getter=isPaused)    BOOL paused;


/// 开始回调。
@property (nonatomic, copy, nullable) void (^onStart)(void);

/// 过程回调。  progress:进度0.0～1.0;  rcvBytes:已接收字节数;
@property (nonatomic, copy, nullable) void (^onProgress)(float progress, int rcvBytes);

/// 完成回调。
@property (nonatomic, copy, nullable) void (^onFinish)(NSString *location);

/// 错误回调。error：错误原因；
@property (nonatomic, copy, nullable) void (^onError)(NSError *error);

/// 取消回调。
@property (nonatomic, copy, nullable) void (^onCancel)(void);


/// 初始化
/// @Note 目前支持"file:"、"https:"、"http:"、“concat:”协议的输入url
///       例如，"file://xxx/aaa.mp4"、"https://xxx/bbb.m3u8"、"concat:PATH0.ts|PATH1.ts|PATH2.ts|..."
- (instancetype)initWithUrl:(NSString *)url
                 saveAtPath:(NSString *)location
                    options:(nullable NSDictionary<NSString *, id> *)options
                    onStart:(nullable void (^)(void))onStart
                 onProgress:(nullable void (^)(float progress, int rcvBytes))onProgress
                   onFinish:(nullable void (^)(NSString *location))onFinish
                    onError:(nullable void (^)(NSError *error))onError
                   onCancel:(nullable void (^)(void))onCancel;

/// 工作流产生的缓存文件存储目录，工作流完成会自动清空。
+ (NSString *)getCachesDirForUrl:(NSString *)url;

/// 开始/恢复
- (void)resume;

/// 暂停，会保留缓存文件
///   A. 若该对象未销毁，可通过`-resume`立即恢复；
///   B. 若该对象销毁后，断点续传功能必须保证保存路径`location`相同；
- (void)suspend;

/// 取消，会自动清空缓存文件
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
