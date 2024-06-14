//
//  IVLanNetConfig.h
//  IoTVideo
//
//  Created by JonorZhang on 2019/12/18.
//  Copyright © 2019 Tencentcs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IVNetConfig.h"

NS_ASSUME_NONNULL_BEGIN

/// 局域网设备模型
@interface IVLANDevice : NSObject
/// device id
@property (nonatomic, copy) NSString *deviceID;
/// 产品ID
@property (nonatomic, copy) NSString *productID;
/// 序列号
@property (nonatomic, copy) NSString *serialNumber;
/// 设备版本
@property (nonatomic, copy) NSString *version;
/// ip地址
@property (nonatomic, copy) NSString *ipAddr;
/// MAC地址
@property (nonatomic, copy) NSString *macAddr;
/// 预留
@property (nonatomic, copy) NSString *reserve;
/// 是否已经被绑定
@property (nonatomic, assign) BOOL hasOwner;
@end

/// 局域网 网络配置类
@interface IVLanNetConfig : NSObject

/// 通过局域网发送配网信息（AP）
///
/// 类型   必选    说明
/// 0      是    wifi-ssid
/// 1      是    wifi密码
/// 2      是    wifi安全/加密选项  无密码:0  WPA:2 SDK内部判断实现
/// 3      否    平台保留
/// 4      否    配网提示音语言类型
/// 5      是    配网token,从IoT Video平台获取
/// 6-9    否    平台扩展保留  0 - 9
/// A-Z    否    厂商自定义扩展 放入 extraInfo 中
///
/// @param name Wi-Fi名称
/// @param pwd Wi-Fi密码
/// @param token 配网token，通过`+[IVNetConfig getBindToken:]`及`+[IVNetConfig getBindToken:callback:]`获取
/// @param deviceId 设备id
/// @param completionHandler 配网结果回调
- (void)sendWifiName:(NSString *)name
        wifiPassword:(NSString *)pwd
               token:(NSString *)token
            toDevice:(NSString *)deviceId
          completion:(IVResultCallback)completionHandler;

/// 通过局域网发送配网信息（AP）
///
/// 类型   必选    说明
/// 0      是    wifi-ssid
/// 1      是    wifi密码
/// 2      是    wifi安全/加密选项  无密码:0  WPA:2 SDK内部判断实现
/// 3      否    平台保留
/// 4      否    配网提示音语言类型
/// 5      是    配网token,从IoT Video平台获取
/// 6-9    否    平台扩展保留  0 - 9
/// A-Z    否    厂商自定义扩展 放入 extraInfo 中
///
/// @param name Wi-Fi名称
/// @param pwd Wi-Fi密码
/// @param language 设备语言
/// @param token 配网token，通过`+[IVNetConfig getBindToken:]`及`+[IVNetConfig getBindToken:callback:]`获取
/// @param extraInfo 额外信息
/// @param deviceId 设备id
/// @param completionHandler 配网结果回调
- (void)sendWifiName:(NSString *)name
        wifiPassword:(NSString *)pwd
            language:(IVNetConfigLanguage)language
               token:(NSString *)token
           extraInfo:(nullable NSDictionary<NSString *, NSString *> *)extraInfo
            toDevice:(NSString *)deviceId
          completion:(IVResultCallback)completionHandler;

/// 获取局域网设备列表
- (NSArray<IVLANDevice *> *)getDeviceList;

/// 验证局域网访问密码
/// 当直接局域网访问时需要调用此命令（具体密码由SAAS固件端设置）
/// @param password 密码
/// @param device 设备id
/// @return see `iv_lan_pwd_ret_e`
- (IVLANPwdResult)checkAccessPassword:(NSString *)password device:(NSString *)device;
                     

/// 修改局域网访问密码
/// @param device 设备id
/// @param oldPassword 旧密码
/// @param newPassword 新密码
/// @return see `iv_lan_pwd_ret_e`
- (IVLANPwdResult)modifyAccessPassword:(NSString *)oldPassword device:(NSString *)device newPassword:(NSString *)newPassword;

@end

NS_ASSUME_NONNULL_END
