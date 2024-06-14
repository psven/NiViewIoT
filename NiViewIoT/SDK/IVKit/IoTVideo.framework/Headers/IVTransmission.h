//
//  IVTransmission.h
//  IoTVideo
//
//  Created by JonorZhang on 2020/5/25.
//  Copyright © 2020 Tencentcs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IVConnection.h"
#import "IVMessageMgr.h"

NS_ASSUME_NONNULL_BEGIN

/// 用户自定义数据传输类
/// 需要与设备建立专门的连接通道，适用于较大数据传输、实时性要求较高的场景，如多媒体数据传输。
@interface IVTransmission : IVConnection

/// 初始化连接
/// @param deviceId 设备ID
- (nullable instancetype)initWithDeviceId:(NSString *)deviceId;

/// 初始化连接
/// @param deviceId 设备ID
/// @param sourceId 源ID，默认为0
- (nullable instancetype)initWithDeviceId:(NSString *)deviceId sourceId:(uint16_t)sourceId;

/// 开始连接
- (void)connect;

/// 断开连接
- (void)disconnect;

/// 发送自定义数据
///
/// 与设备建立连接后才可发送，适用于较大数据传输、实时性要求较高的场景，如多媒体数据传输。
/// 接收到设备端发来的数据见`-[IVConnectionDelegate connection:didReceiveData:]`
/// @param data 要发送的数据，data.length不能超过`MAX_PKG_BYTES`
/// @return 发送是否成功
- (BOOL)sendData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
