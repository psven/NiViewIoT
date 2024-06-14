//
//  IVPlaybackPlayer.h
//  IoTVideo
//
//  Created by JonorZhang on 2019/11/20.
//  Copyright © 2019 Tencentcs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IVPlayer.h"
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 回放文件
@interface IVPlaybackItem: NSObject<NSCopying>
/// 回放文件起始时间（秒），用UTC+0表示
@property (nonatomic, assign, getter=fileTime) NSTimeInterval startTime;
/// 回放文件结束时间（秒），用UTC+0表示
@property (nonatomic, assign) NSTimeInterval endTime;
/// 回放文件持续时间（秒），duration = endTime - startTime
@property (nonatomic, assign) NSTimeInterval duration;
/// 回放文件类型（例如手动录像、人形侦测等，由设备端应用层定义）
@property (nonatomic, strong) NSString      *type;
@end

/// 回放文件分页
@interface IVPlaybackPage<PBItem>: NSObject
/// 当前页码索引
@property (nonatomic, assign) uint32_t  pageIndex;
/// 总页数
@property (nonatomic, assign) uint32_t  totalPage;
/// 回放文件数组
@property (nonatomic, strong) NSArray<PBItem> *items;
@end

/// 回放文件切换策略
typedef NS_ENUM(NSUInteger, IVPlaybackStrategy) {
    /// 按文件开始时间从小到大（升序）自动播放，默认值
    IVPlaybackStrategy_Ascending,
    /// 按文件开始时间从大到小（降序）自动播放
    IVPlaybackStrategy_Descending,
    /// 播放单个文件，播完自动暂停
    IVPlaybackStrategy_Single,
};

/// 文件操作结果
@interface IVFileOpStat: NSObject
/// 文件起始时间 [ms]
@property (nonatomic, assign) uint64_t fileTime;
/// 错误码，见 @c `IVFileDelErr`
@property (nonatomic, assign) uint64_t errCode;
@end

/// 回放文件获取回调
typedef void (^PlaybackListCallback)(IVPlaybackPage<IVPlaybackItem *> *_Nullable page, NSError *_Nullable error);
/// 回放日期获取回调（日期为当天0点），用UTC+0表示
typedef void (^PlaybackDateCallback)(IVPlaybackPage<NSNumber *> *_Nullable page, NSError *_Nullable error);

/// 回放播放器
@interface IVPlaybackPlayer : IVPlayer

/// 创建空播放器
/// @param deviceId 设备ID
- (nullable instancetype)initWithDeviceId:(NSString *)deviceId;

/// 创建空播放器
/// @param deviceId 设备ID
/// @param sourceId 源ID，默认为0
- (nullable instancetype)initWithDeviceId:(NSString *)deviceId sourceId:(uint16_t)sourceId;

/// 创建播放器同时设置回放参数
/// @param deviceId 设备ID
/// @param item 播放的文件(可跨文件)
/// @param time 指定播放起始时间点（秒），取值范围`playbackItem.startTime >= time <= playbackItem.endTime`
- (nullable instancetype)initWithDeviceId:(NSString *)deviceId playbackItem:(IVPlaybackItem *)item seekToTime:(NSTimeInterval)time;

/// 创建播放器同时设置回放参数
/// @param deviceId 设备ID
/// @param sourceId 源ID
/// @param item 播放的文件(可跨文件)
/// @param time 指定播放起始时间点（秒），取值范围`playbackItem.startTime >= time <= playbackItem.endTime`
- (nullable instancetype)initWithDeviceId:(NSString *)deviceId sourceId:(uint16_t)sourceId playbackItem:(IVPlaybackItem *)item seekToTime:(NSTimeInterval)time;

/// 获取一页回放文件列表
/// @param deviceId 设备ID
/// @param pageIndex 页码索引，获取指定页码的回放文件（ pageIndex从0开始），在未知总页数情况下传0
/// @param countPerPage 在[startTime, endTime]时间范围内按每页`countPerPage`个文件查询，每次返回一页的数据，该值由APP设置，取值范围[1, 3200]
/// @param startTime 开始时间戳（秒），用UTC+0表示
/// @param endTime 结束时间戳（秒），用UTC+0表示
/// @param filterType 筛选指定类型文件, nil为不筛选
/// @param ascendingOrder 是否按时间递增顺序(即从startTime到endTime方向)获取文件
/// @param completionHandler 结果回调
/// @note ⚠️请根据实际情况合理设置查询时间范围和分页，`时间跨度太长`或`每页数量过大`会增加设备查询时间， 建议[startTime, endTime]区间不超过24小时 或 countPerPage不超过1440个文件.
+ (void)getPlaybackListOfDevice:(NSString *)deviceId
                      pageIndex:(uint32_t)pageIndex
                   countPerPage:(uint32_t)countPerPage
                      startTime:(NSTimeInterval)startTime
                        endTime:(NSTimeInterval)endTime
                     filterType:(nullable NSString *)filterType
                 ascendingOrder:(BOOL)ascendingOrder
              completionHandler:(PlaybackListCallback)completionHandler;

/// 获取有回放文件的日期列表
/// @param deviceId 设备ID
/// @param pageIndex 页码索引，获取指定页码的回放文件（ pageIndex从0开始递增）
/// @param countPerPage 在[startTime, endTime]时间范围内按每页`countPerPage`个文件查询，每次返回一页的数据，该值由APP设置，取值范围[1, 3200]
/// @param startTime 开始时间戳（秒），用UTC+0表示
/// @param endTime 结束时间戳（秒），用UTC+0表示
/// @param completionHandler 结果回调
+ (void)getDateListOfDevice:(NSString *)deviceId
                  pageIndex:(uint32_t)pageIndex
               countPerPage:(uint32_t)countPerPage
                  startTime:(NSTimeInterval)startTime
                    endTime:(NSTimeInterval)endTime
          completionHandler:(PlaybackDateCallback)completionHandler;


/// 删除过程回调, fail_list：本批次失败列表， total_del_cnt：累计成功删除个数， total_fail_cnt：累计失败个数 。
typedef void(^IVFileDeleteCB)(NSArray<IVFileOpStat *> *fail_list, uint32_t total_del_cnt, uint32_t total_fail_cnt);

/// 按 时间范围 删除卡回放文件
/// @param deviceId 设备ID
/// @param startTime 开始时间戳（秒），用UTC+0表示，endTime - startTime最大是一天
/// @param endTime 结束时间戳（秒），用UTC+0表示
/// @param filterType 指定类型文件, nil为不指定
/// @param progress 删除过程回调，文件太多可能回调多次， @c `IVFileDeleteCB`。
/// @param finished 任务结束回调，错误码参考  @c `IVFileDelErr`、`IVConnError`和`IVPlaybackError`
+ (void)deletePlaybackFilesOfDevice:(NSString *)deviceId
                          startTime:(NSTimeInterval)startTime
                            endTime:(NSTimeInterval)endTime
                         filterType:(nullable NSString *)filterType
                           progress:(IVFileDeleteCB)progress
                           finished:(void (^)(NSError *_Nullable error))finished;

/// 按 文件列表 删除卡回放文件
/// @param deviceId 设备ID
/// @param fileTimes 要删除的文件的开始时间(ms, [uint64_t])数组, 用于识别是哪些文件. 参考 @c `IVPlaybackItem.startTime`
/// @param progress 删除过程回调，文件太多可能回调多次， @c `IVFileDeleteCB` 。
/// @param finished 任务结束回调，错误码参考  @c `IVFileDelErr`、`IVConnError`和`IVPlaybackError`
+ (void)deletePlaybackFilesOfDevice:(NSString *)deviceId
                          fileTimes:(NSArray *)fileTimes
                           progress:(IVFileDeleteCB)progress
                           finished:(void (^)(NSError *_Nullable error))finished;

/// 终止删除操作
+ (void)cancelDeletePlaybackFilesOfDevice:(NSString *)deviceId finished:(void (^)(NSError *_Nullable error))completionHandler;

/// (未播放前)设置回放参数.
/// @note 应在文件尚未播放时使用，需手动调用`play`开始播放.
/// @param item 播放的文件(可跨文件).
/// @param time 指定播放起始时间点（秒），取值范围`playbackItem.startTime >= time <= playbackItem.endTime`.
- (void)setPlaybackItem:(IVPlaybackItem *)item seekToTime:(NSTimeInterval)time;

/// (已播放后)跳到指定文件和时间播放
/// @note 应在文件正在播放时使用, 无需再手动调用`play`开始播放
/// @param time 指定播放起始时间点（秒），取值范围`playbackItem.startTime >= time <= playbackItem.endTime`
/// @param item 播放的文件(可跨文件)
- (void)seekToTime:(NSTimeInterval)time playbackItem:(IVPlaybackItem *)item;

/// (已播放后)跳到指定文件和时间播放
- (void)seekToTime:(NSTimeInterval)time playbackItem:(IVPlaybackItem *)item completionHandler:(nullable IVCommandSettingCallback)completionHandler;

/// 当前回放的文件。
/// @note 当前回放时间通过`-[IVPlayer pts]`获取
@property (nonatomic, strong, nullable, readonly) IVPlaybackItem *playbackItem;

/// 回放策略。默认`IVPlaybackStrategy_Ascending`，setter方法等于`-[setPlaybackStrategy:xx completionHandler:nil]`
@property (nonatomic, assign) IVPlaybackStrategy playbackStrategy;

/// 设置回放策略
- (void)setPlaybackStrategy:(IVPlaybackStrategy)strategy completionHandler:(nullable IVPropertySettingCallback)completionHandler;

/// 回放倍速。setter方法等于`-[setPlaybackSpeed:xx completionHandler:nil]`
/// 默认1.0, 一般取值范围[0.5~16.0], SDK允许传参范围(0.0~32.0]，开发者应视设备性能而定!
/// @note 超过2倍速后设备是不会发音频的，并且视频只有关键帧
@property (nonatomic, assign) float playbackSpeed;

/// 设置回放倍速
- (void)setPlaybackSpeed:(float)speed completionHandler:(nullable IVPropertySettingCallback)completionHandler;

/// 暂停
- (void)pause;
- (void)pause:(nullable IVCommandSettingCallback)completionHandler;

/// 恢复
- (void)resume;
- (void)resume:(nullable IVCommandSettingCallback)completionHandler;

@end


@interface IVPlaybackPlayer (Deprecated)

/// 获取一页回放文件列表（已过期）
/// @param deviceId 设备ID
/// @param pageIndex 页码索引，获取指定页码的回放文件（ pageIndex从0开始递增）
/// @param countPerPage 在[startTime, endTime]时间范围内按每页`countPerPage`个文件查询，每次返回一页的数据，该值由APP设置，取值范围[1, 3200]
/// @param startTime 开始时间戳（秒），用UTC+0表示
/// @param endTime 结束时间戳（秒），用UTC+0表示
/// @param filterType 过滤文件类型, nil为不过滤
/// @param completionHandler 结果回调
/// @note ⚠️请根据实际情况合理设置查询时间范围和分页，`时间跨度太长`或`每页数量过大`会增加设备查询时间， 建议[startTime, endTime]区间不超过24小时 或 countPerPage不超过1440个文件.
/// @deprecated Use `-getPlaybackListOfDevice:pageIndex:countPerPage:startTime:endTime:filterType:ascendingOrder:completionHandler:` instead.
+ (void)getPlaybackListV2OfDevice:(NSString *)deviceId
                        pageIndex:(uint32_t)pageIndex
                     countPerPage:(uint32_t)countPerPage
                        startTime:(NSTimeInterval)startTime
                          endTime:(NSTimeInterval)endTime
                       filterType:(nullable NSString *)filterType
                completionHandler:(PlaybackListCallback)completionHandler API_DEPRECATED("Use -getPlaybackListOfDevice:pageIndex:countPerPage:startTime:endTime:filterType:ascendingOrder:completionHandler: instead", ios(2.0,9.0));

/// 获取一页回放文件列表（已过期）
/// @param deviceId 设备ID
/// @param pageIndex 页码索引，获取指定页码的回放文件（ pageIndex从0开始递增）
/// @param countPerPage 在[startTime, endTime]时间范围内按每页`countPerPage`个文件查询，每次返回一页的数据，该值由APP设置，取值范围[1, 900]
/// @param startTime 开始时间戳（秒）
/// @param endTime 结束时间戳（秒）
/// @param completionHandler 结果回调
/// @note ⚠️请根据实际情况合理设置查询时间范围和分页，`时间跨度太长`或`每页数量过大`会增加设备查询时间， 建议[startTime, endTime]区间不超过12小时 或 countPerPage不超过720个文件.
/// @deprecated Use `-getPlaybackListOfDevice:pageIndex:countPerPage:startTime:endTime:filterType:ascendingOrder:completionHandler:` instead.
+ (void)getPlaybackListOfDevice:(NSString *)deviceId
                      pageIndex:(uint32_t)pageIndex
                   countPerPage:(uint32_t)countPerPage
                      startTime:(NSTimeInterval)startTime
                        endTime:(NSTimeInterval)endTime
              completionHandler:(PlaybackListCallback)completionHandler API_DEPRECATED("Use -getPlaybackListOfDevice:pageIndex:countPerPage:startTime:endTime:filterType:ascendingOrder:completionHandler: instead", ios(2.0,9.0));

@end

NS_ASSUME_NONNULL_END

