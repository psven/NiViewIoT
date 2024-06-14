//
//  IVNetConfig.h
//  IoTVideo
//
//  Created by ZhaoYong on 2020/1/8.
//  Copyright © 2020 Tencentcs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IVConstant.h"
#import "IVError.h"

NS_ASSUME_NONNULL_BEGIN

typedef IVLanguageCode IVNetConfigLanguage;

/// 通用的处理回调
/// succ： 成功与否
/// error： 成功时为nil， 失败时为错误原因
typedef void(^IVResultCallback)(BOOL succ, NSError * _Nullable error);

/// 获取配网BindToken回调
typedef void(^IVNetCfgTokenCallback)(NSString * _Nullable bindToken, NSError * _Nullable error);

/// 查询配网结果回调/设备可绑定状态
/// 若可绑定，请参考接口[终端用户绑定设备](https://cloud.tencent.com/document/product/1131/42367) 绑定设备
/// deviceId: 设备id
/// error:  【nil】配网成功；【非nil】配网失败，@c `IVNetCfgErr`
typedef void(^IVDeviceOnlineCallback)(NSString * _Nullable deviceId, NSError * _Nullable error);


@class IVLanNetConfig, IVQRCodeNetConfig;


/// 配网管理
@interface IVNetConfig : NSObject

/// 局域网配网
@property(class, nonatomic, strong, readonly) IVLanNetConfig *lan;

/// 二维码配网
@property(class, nonatomic, strong, readonly) IVQRCodeNetConfig *QRCode;


/// 监听配网结果回调/设备可绑定状态
/// 若可绑定，请参考接口[终端用户绑定设备](https://cloud.tencent.com/document/product/1131/42367) 绑定设备
/// @param completionHandler 结果回调
+ (void)observeNetCfgResult:(IVDeviceOnlineCallback)completionHandler;

/// 移除配网监听
+ (void)removeObserver;

/// 获取二维码/AP 配网所需要的配网 BindToken
/// BindToken过期时间默认300秒
/// @param completionHandler 回调
+ (void)getBindToken:(IVNetCfgTokenCallback)completionHandler;
   
/// 获取二维码/AP 配网所需要的配网 BindToken, 自定义BindToken过期时间
/// BindToken过期时间默认300秒
/// @param deviceId 设备ID [可选]
/// @param completionHandler 结果回调
+ (void)getBindToken:(nullable NSString *)deviceId callback:(IVNetCfgTokenCallback)completionHandler;

/// 获取二维码/AP 配网所需要的配网 BindToken, 自定义BindToken过期时间
/// @param deviceId 设备ID [可选]
/// @param expireTime 设定BindToken过期时间(秒，默认300)，范围[1,3600]
/// @param completionHandler 结果回调
+ (void)getBindToken:(nullable NSString *)deviceId expireTime:(NSUInteger)expireTime callback:(IVNetCfgTokenCallback)completionHandler;

/// 通过web绑定成功后，快速订阅设备，这样才能操作设备
/// @param accessToken 设备访问授权AccessToken，请注意不是用户登录成功得到的accessToken也不是BindToken，而是通过 [终端用户绑定设备接口](https://cloud.tencent.com/document/product/1131/42367) 返回结果获得。
/// @param deviceId 设备ID
/// @param completionHandler  结果回调
+ (void)subscribeDeviceWithAccessToken:(NSString *)accessToken deviceId:(NSString *)deviceId callback:(IVResultCallback)completionHandler;

@end

@interface IVNetConfig (Deprecated)

/// 通过web绑定成功后，快速订阅设备
/// @param accessToken 设备访问授权AccessToken，请注意不是用户登录成功得到的accessToken也不是BindToken，而是通过 [终端用户绑定设备接口](https://cloud.tencent.com/document/product/1131/42367) 返回结果获得。
/// @param deviceId 设备ID
/// @return 是否成功
+ (BOOL)subscribeDeviceWithAccessToken:(NSString *)accessToken deviceId:(NSString *)deviceId API_DEPRECATED("Use +subscribeDeviceWithAccessToken:deviceId:callback: instaed", ios(2.0,9.0));;

@end

NS_ASSUME_NONNULL_END
