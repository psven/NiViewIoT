//
//  IVConnection.h
//  IoTVideo
//
//  Created by JonorZhang on 2020/5/25.
//  Copyright © 2020 Tencentcs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IVError.h"

NS_ASSUME_NONNULL_BEGIN

/// APP端可以同时与(多台)设备建立的最大连接个数
#define MAX_CONNECTION_NUM 16

/// 单次用户自定义数据大小上限（字节）
#define MAX_PKG_BYTES 64000

/// 连接类型
typedef NS_ENUM(NSUInteger, IVConnType) {
    /// 视频呼叫，双向音视频
    IVConnTypeLive          = 0,
    /// 监控，单向视频，双向音频（对讲）
    IVConnTypeMonitor       = 1,
    /// 录像回放
    IVConnTypePlayback      = 2,
    /// 数据透传
    IVConnTypeTransmission  = 3,
    /// 文件下载
    IVConnTypeFileDownload  = 6,
    /// 缩略图下载
    IVConnTypeThumbDownload = 7,
};

/// 连接状态
typedef NS_ENUM(NSInteger, IVConnStatus) {
    /// 断开中...
    IVConnStatusDisconnecting   = -1,
    /// 已断开
    IVConnStatusDisconnected    = 0,
    /// 连接中...
    IVConnStatusConnecting      = 1,
    /// 已连接
    IVConnStatusConnected       = 2,
};

/// 连接过程子状态
/// @note 部分设备/场景是没有子状态的
typedef NS_ENUM(NSInteger, IVConnectingSubstate) {
    /// 服务器已收到连接请求，正在唤醒设备
    IVConnectingSubstate_WakingUpDev  = 1,
    /// 设备已收到唤醒通知，开始握手过程
    IVConnectingSubstate_Handshaking  = 2,
    /// 握手过程完成，连接通道已就绪
    IVConnectingSubstate_ConnectReady = 3,
};

@class IVConnection;


/// 连接代理
@protocol IVConnectionDelegate <NSObject>

@optional

/// 状态更新
/// @param connection 连接实例
/// @param status 状态
- (void)connection:(IVConnection *)connection didUpdateStatus:(IVConnStatus)status;

/// 连接过程子状态更新
/// @note 部分设备/场景是没有子状态的，此代理方法不一定有回调
/// @param connection 连接实例
/// @param substate 连接过程子状态
- (void)connection:(IVConnection *)connection didUpdateConnectingSubstate:(IVConnectingSubstate)substate;

/// 数据接收速率
/// @param connection 连接实例
/// @param speed 接收速率(字节/秒)
- (void)connection:(IVConnection *)connection didUpdateSpeed:(uint32_t)speed;

/// 收到错误
/// @param connection 连接实例
/// @param error 错误, 见`IVConnError` / [`IVError`、`IVLinkStatus`]
- (void)connection:(IVConnection *)connection didReceiveError:(NSError *)error;

/// 收到数据
/// @param connection 连接实例
/// @param data 数据
- (void)connection:(IVConnection *)connection didReceiveData:(NSData *)data;

@end


/// 通道连接类
/// @note 该类是抽象基类，请勿直接实例化，应使用其派生类: IVPlayer（IVMonitorPlayer、IVLivePlayer、IVPlaybackPlayer）、IVTransmission 和 IVFileDownloader
@interface IVConnection: NSObject

/// 连接代理
@property (nonatomic, weak, nullable) id<IVConnectionDelegate> delegate;

/// 设备ID
@property (nonatomic, strong, readonly) NSString *deviceId;

/// 源ID（一个设备 可以对应 多个源），默认为0
@property (nonatomic, assign, readonly) uint16_t sourceId;

/// 通道ID，连接成功该值才有效（一个设备+一个源 对应 唯一通道），无效值为-1
@property (nonatomic, assign, readonly) uint32_t channel;

/// 连接类型
@property (nonatomic, assign, readonly) IVConnType connType;

/// 连接状态
@property (nonatomic, assign, readonly) IVConnStatus connStatus;

@end


NS_ASSUME_NONNULL_END
