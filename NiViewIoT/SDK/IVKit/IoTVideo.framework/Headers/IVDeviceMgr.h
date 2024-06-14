//
//  IVDeviceMgr.h
//  IoTVideo
//
//  Created by zhaoyong on 2020/10/27.
//  Copyright © 2020 Tencentcs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IVNetwork_p2p.h"

NS_ASSUME_NONNULL_BEGIN

@interface IVDeviceMgr : NSObject

/// 查询设备新固件版本信息
/// @param deviceId 设备id
/// @param responseHandler 回调
+ (void)queryDeviceNewVersionWidthDevieId:(NSString *)deviceId responseHandler:(IVNetworkResponseHandler)responseHandler;


/// 查询设备新固件版本信息
/// @param deviceId 设备id
/// @param currentVersion 当前设备版本号。nil:默认为当前设备版本号；新版本固件可以指定哪些设备版本可以查询到有固件更新，这种场景下[不传版本] 和 [不在指定版本列表里面]就查询不到更新
/// @param language 语言 nil：默认系统语言
/// @param responseHandler 回调
+ (void)queryDeviceNewVersionWidthDevieId:(NSString *)deviceId currentVersion:(NSString * _Nullable)currentVersion language:(NSString * _Nullable)language responseHandler:(IVNetworkResponseHandler)responseHandler;


@end

NS_ASSUME_NONNULL_END
