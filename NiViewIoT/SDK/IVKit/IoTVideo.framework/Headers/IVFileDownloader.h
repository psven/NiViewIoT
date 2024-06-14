//
//  IVFileDownloader.h
//  IoTVideo
//
//  Created by JonorZhang on 2021/3/16.
//  Copyright © 2021 Tencentcs. All rights reserved.
//

#import "IVConnection.h"
#import "IVError.h"

NS_ASSUME_NONNULL_BEGIN

/// 下载器状态
typedef NS_ENUM(NSInteger, IVDownloaderStatus) {
    /// 空闲中
    IVDownloaderStatusIdle          = 0,
    /// 请求文件中
    IVDownloaderStatusRequesting    = 1,
    /// 已就绪（即将下载数据）
    IVDownloaderStatusReady         = 2,
    /// 下载中...
    IVDownloaderStatusLoading       = 3,
};

#pragma mark - 回放文件下载器

/// 回放文件下载器
@interface IVFileDownloader : IVConnection

/// 下载器状态
@property (nonatomic, assign, readonly) IVDownloaderStatus status;

/// 原始文件名（即文件在设备端的名称）
@property (nonatomic, strong, readonly, nullable) NSString *fileName;

/// 文件的开始时间（ms）（用于识别是哪个文件）
@property (nonatomic, assign, readonly) uint64_t fileTime;

/// 文件总大小（字节）
@property (nonatomic, assign, readonly) uint32_t fileSize;

/// 文件已下载大小（字节），初始值等于文件偏移量
@property (nonatomic, assign, readonly) uint32_t rcvSize;

/// 创建下载器
/// @param deviceId 设备ID
- (nullable instancetype)initWithDeviceId:(NSString *)deviceId;

/// 创建下载器
/// @param deviceId 设备ID
/// @param sourceId 源ID，默认为0
- (nullable instancetype)initWithDeviceId:(NSString *)deviceId sourceId:(uint16_t)sourceId;

/// 开始下载回放文件（恢复下载）
/// 此方法内部会自动建立连接，支持断点续传
/// 设备在发送文件完毕后会等待新的下载动作，超过10秒还没有收到任何动作，设备会主动断开连接(20136）。
/// @note 一台设备同一时间内只能下载一个文件，若要切换下载的文件请先暂停当前下载的文件。
/// @param fileTime 要下载的文件的开始时间(ms, uint64_t), 用于识别是哪个文件 @c `IVPlaybackItem.startTime`
/// @param offset 断点续传时填字节偏移量（即当前已下载字节数），重新下载填0
/// @param ready 文件已就绪回调，即将接收数据，`fileSize`:文件总大小
/// @param progress 下载过程回调，可能回调多次，`data`:文件内容
/// @param canceled 下载取消回调
/// @param success 下载完成回调
/// @param failure 下载失败回调,  @c `IVConnError`和`IVDownloadError`
- (void)downloadPlaybackFile:(uint64_t)fileTime
                      offset:(uint32_t)offset
                       ready:(void (^)(uint32_t fileSize))ready
                    progress:(void (^)(NSData *data))progress
                    canceled:(void (^)(void))canceled
                     success:(void (^)(void))success
                     failure:(void (^)(NSError *error))failure;

/// 取消下载
/// 设备将取消本次传输，然后进入10秒倒计时，若期间没有收到任何动作，设备会主动断开连接(20136）
- (void)cancel;

/// 停止下载，并断开与设备的连接
- (void)stop;

@end

#pragma mark - 缩略图下载器

/// 缩略图下载器
@interface IVThumbnailDownloader : IVConnection

/// 下载器状态
@property (nonatomic, assign, readonly) IVDownloaderStatus status;

/// 创建下载器
/// @param deviceId 设备ID
- (nullable instancetype)initWithDeviceId:(NSString *)deviceId;

/// 创建下载器
/// @param deviceId 设备ID
/// @param sourceId 源ID，默认为0
- (nullable instancetype)initWithDeviceId:(NSString *)deviceId sourceId:(uint16_t)sourceId;

/// 批量下载缩略图
/// 此方法内部会自动建立连接，不支持断点续传
/// @param fileTimes 要下载的缩略图对应的文件的开始时间(ms, [uint64_t])数组, 用于识别是哪些文件. 参考@c `IVPlaybackItem.startTime`
/// @param progress 下载过程数据回调，每张图片回调一次，批量下载时会有多次回调，若成功则data非空，若失败则error非空，错误码参考@c `IVDownloadError`。
/// @param canceled 下载任务被取消回调
/// @param finished 下载任务完成回调，错误码参考  @c `IVConnError`和`IVDownloadError`
- (void)downloadThumbnails:(NSArray *)fileTimes
                  progress:(void (^)(uint64_t fileTime, NSData *_Nullable data, NSError *_Nullable error))progress
                  canceled:(void (^)(void))canceled
                  finished:(void (^)(NSError *_Nullable error))finished;

/// 取消下载
/// 设备将取消本次传输，然后进入10秒倒计时，若期间没有收到任何动作，设备会主动断开连接(20136）
- (void)cancel;

/// 停止下载，并断开与设备的连接
- (void)stop;

@end


NS_ASSUME_NONNULL_END
