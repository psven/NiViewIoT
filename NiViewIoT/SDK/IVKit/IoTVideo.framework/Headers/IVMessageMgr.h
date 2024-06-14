//
//  IVMessageMgr.h
//  IoTVideo
//
//  Created by JonorZhang on 2019/11/27.
//  Copyright © 2019 Tencentcs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IVError.h"

NS_ASSUME_NONNULL_BEGIN

// 超时时间填0表示使用默认值
#define IVMsgTimeoutAuto  0.0

/// 单次JSON响应回调
typedef void(^IVMsgJSONCallback)(NSString * _Nullable json, NSError * _Nullable error);
/// 单次数据响应回调
typedef void(^IVMsgDataCallback)(NSData * _Nullable data, NSError * _Nullable error);
/// 多次数据响应回调     ⚠️不需要响应或结束响应后由APP开发者设置 `*finished = YES`，SDK内部就会移除响应监听！
typedef void(^IVMsgMultiRspCallback)(NSData * _Nullable data, NSError * _Nullable error, BOOL *finished);

@class IVMessageMgr;

/// 消息代理协议
@protocol IVMessageDelegate <NSObject>

@optional
/// 接收到事件消息（Event）:  告警、分享、系统通知
/// @param event 事件消息体
/// @param topic 请参照物模型定义
- (void)didReceiveEvent:(NSString *)event topic:(NSString *)topic;

/// 接收到只读属性消息（ProReadonly.xxx.stVal / Action.xxx.stVal）
/// @param json 内容（JSON的具体字符串）
/// @param path 路径（JSON的叶子节点）
/// @param deviceId 设备ID
- (void)didUpdateProperty:(NSString *)json path:(NSString *)path deviceId:(NSString *)deviceId;

/// 接收到设备发起的透传数据
/// @param data 数据
/// @param deviceId 设备ID
- (void)didReceivePassthroughData:(NSData *)data deviceId:(NSString *)deviceId;

@end


/// 消息管理类
@interface IVMessageMgr : NSObject

/// 消息管理单例
@property (class, nonatomic, strong, readonly) IVMessageMgr *sharedInstance;
+ (instancetype)sharedInstance;

/// 消息代理
@property (nonatomic, weak) id<IVMessageDelegate> delegate;

/// 全局消息默认超时时间，10秒，不可修改， 单个消息可以单独设置
@property (nonatomic, assign, readonly) NSTimeInterval defaultTimeout;

/// 是否允许消息重复发送，默认NO
@property (nonatomic, assign) BOOL allowDuplicateSending;


#pragma mark - 物模型方法

/// 写入属性
/// @param deviceId 设备ID
/// @param path 路径（JSON的叶子节点）
/// @param json  内容（JSON的具体字符串）
/// @param completionHandler 完成回调
- (void)writePropertyOfDevice:(NSString *)deviceId
                         path:(NSString *)path
                         json:(NSString *)json
            completionHandler:(nullable IVMsgJSONCallback)completionHandler;

/// 写入属性
/// @param deviceId 设备ID
/// @param path 路径（JSON的叶子节点）
/// @param json  内容（JSON的具体字符串）
/// @param timeout 超时时间
/// @param completionHandler 完成回调
- (void)writePropertyOfDevice:(NSString *)deviceId
                         path:(NSString *)path
                         json:(NSString *)json
                      timeout:(NSTimeInterval)timeout
            completionHandler:(nullable IVMsgJSONCallback)completionHandler;

/// 读取属性
/// @param deviceId 设备ID
/// @param path 路径（JSON的叶子节点）
/// @param completionHandler 完成回调
- (void)readPropertyOfDevice:(NSString *)deviceId
                        path:(NSString *)path
           completionHandler:(nullable IVMsgJSONCallback)completionHandler;

/// 读取属性
/// @param deviceId 设备ID
/// @param path 路径（JSON的叶子节点）
/// @param timeout 超时时间
/// @param completionHandler 完成回调
- (void)readPropertyOfDevice:(NSString *)deviceId
                        path:(NSString *)path
                     timeout:(NSTimeInterval)timeout
           completionHandler:(nullable IVMsgJSONCallback)completionHandler;

/// 执行动作
/// @param deviceId 设备ID
/// @param path 路径（JSON的叶子节点）
/// @param json  内容（JSON的具体字符串）
/// @param completionHandler 完成回调
- (void)takeActionOfDevice:(NSString *)deviceId
                      path:(NSString *)path
                      json:(NSString *)json
         completionHandler:(nullable IVMsgJSONCallback)completionHandler;

/// 执行动作
/// @param deviceId 设备ID
/// @param path 路径（JSON的叶子节点）
/// @param json  内容（JSON的具体字符串）
/// @param timeout 超时时间
/// @param completionHandler 完成回调
- (void)takeActionOfDevice:(NSString *)deviceId
                      path:(NSString *)path
                      json:(NSString *)json
                   timeout:(NSTimeInterval)timeout
         completionHandler:(nullable IVMsgJSONCallback)completionHandler;

/// 新增 自定义用户物模型
///
/// 新增与已有的自定义重复时，会直接覆盖
/// @param deviceId 设备ID
/// @param path 路径（ProUser.xxx）不得以 "_"开头
/// @param json 内容（JSON的具体字符串）
/// @param completionHandler 完成回调
- (void)addPropertyOfDevice:(NSString *)deviceId
                       path:(NSString *)path
                       json:(NSString *)json
          completionHandler:(nullable IVMsgJSONCallback)completionHandler;

/// 新增 自定义用户物模型
///
/// 新增与已有的自定义重复时，会直接覆盖
/// @param deviceId 设备ID
/// @param path 路径（ProUser.xxx）不得以 "_"开头
/// @param json 内容（JSON的具体字符串）
/// @param timeout 超时时间
/// @param completionHandler 完成回调
- (void)addPropertyOfDevice:(NSString *)deviceId
                       path:(NSString *)path
                       json:(NSString *)json
                    timeout:(NSTimeInterval)timeout
          completionHandler:(nullable IVMsgJSONCallback)completionHandler;

/// 删除 自定义用户物模型
/// @param deviceId 设备ID
/// @param path 路径（ProUser.xxx）只能删除自定义新增的内容
/// @param completionHandler 完成回调
- (void)deletePropertyOfDevice:(NSString *)deviceId
                          path:(NSString *)path
             completionHandler:(nullable IVMsgJSONCallback)completionHandler;

/// 删除 自定义用户物模型
/// @param deviceId 设备ID
/// @param path 路径（ProUser.xxx）只能删除自定义新增的内容
/// @param timeout 超时时间
/// @param completionHandler 完成回调
- (void)deletePropertyOfDevice:(NSString *)deviceId
                          path:(NSString *)path
                       timeout:(NSTimeInterval)timeout
             completionHandler:(nullable IVMsgJSONCallback)completionHandler;

#pragma mark - 信令数据透传

/// 单次信令数据透传上限（字节）
#define MAX_DATA_SIZE 30000

/// 信令数据透传给设备（无数据回传）
///
/// 不需要建立通道连接，数据经由服务器转发，适用于实时性不高、数据小于`MAX_DATA_SIZE`、不需要回传的场景，如控制指令。
/// @note 完成回调条件：收到ACK 或 消息超时
/// @param deviceId 设备ID
/// @param data 数据内容，data.length不能超过`MAX_DATA_SIZE`
/// @param completionHandler 完成回调
- (void)sendDataToDevice:(NSString *)deviceId
                    data:(NSData *)data
         withoutResponse:(nullable IVMsgDataCallback)completionHandler;

/// 信令数据透传给设备（单次数据回传）
///
/// 不需要建立通道连接，数据经由服务器转发，适用于实时性不高、数据小于`MAX_DATA_SIZE`、需要回传的场景，如获取信息。
/// @note 完成回调条件：收到ACK错误、消息超时 或 有数据回传
/// @param deviceId 设备ID
/// @param data 数据内容，data.length不能超过`MAX_DATA_SIZE`
/// @param completionHandler 完成回调
- (void)sendDataToDevice:(NSString *)deviceId
                    data:(NSData *)data
            withResponse:(nullable IVMsgDataCallback)completionHandler;

/// 信令数据透传给设备（可多次数据回传）
///
/// 不需要建立通道连接，数据经由服务器转发，适用于实时性不高、数据小于`MAX_DATA_SIZE`、需要多次回传的场景，如获取信息。
/// @note 完成回调条件：收到ACK错误、消息超时 或 有数据回传
/// @param deviceId 设备ID
/// @param data 数据内容，data.length不能超过`MAX_DATA_SIZE`
/// @param timeout 自定义超时时间，默认超时时间可使用@c `IVMsgTimeoutAuto`
/// @param wakeupDevice 是否唤醒设备，不带此参数的方法均默认YES（即唤醒设备）
/// @param multiRspHandler 多次回调处理, 调用方应在结束回调时设置`*finished=YES`以移除回调监听
- (void)sendDataToDevice:(NSString *)deviceId
                    data:(NSData *)data
                 timeout:(NSTimeInterval)timeout
            wakeupDevice:(BOOL)wakeupDevice
         multiRspHandler:(nullable IVMsgMultiRspCallback)multiRspHandler;

/// 信令数据透传给设备（自定义回传方式）
///
/// 不需要建立通道连接，数据经由服务器转发，适用于实时性要求不高，数据小于`MAX_DATA_SIZE`的场景，如控制指令、获取信息。
/// @note 相关接口 @c `sendDataToDevice:data:withoutResponse:`、`sendDataToDevice:data:withResponse:`。
/// @param deviceId 设备ID
/// @param data 数据内容，data.length不能超过`MAX_DATA_SIZE`
/// @param timeout 自定义超时时间，默认超时时间可使用@c `IVMsgTimeoutAuto`
/// @param wakeupDevice 是否唤醒设备，不带此参数的方法均默认YES（即唤醒设备）
/// @param expectResponse 【YES】预期有数据回传 ；【NO】忽略数据回传
/// @param completionHandler 完成回调
- (void)sendDataToDevice:(NSString *)deviceId
                    data:(NSData *)data
                 timeout:(NSTimeInterval)timeout
            wakeupDevice:(BOOL)wakeupDevice
          expectResponse:(BOOL)expectResponse
       completionHandler:(nullable IVMsgDataCallback)completionHandler;

/// 信令数据透传给服务器
/// @param url 服务器路径
/// @param data 数据内容，data.length不能超过`MAX_DATA_SIZE`
/// @param completionHandler 完成回调
- (void)sendDataToServer:(NSString *)url
                    data:(nullable NSData *)data
       completionHandler:(nullable IVMsgDataCallback)completionHandler;


/// 信令数据透传给服务器
/// @param url 服务器路径
/// @param data 数据内容，data.length不能超过`MAX_DATA_SIZE`
/// @param timeout 超时时间
/// @param completionHandler 完成回调
- (void)sendDataToServer:(NSString *)url
                    data:(nullable NSData *)data
                 timeout:(NSTimeInterval)timeout
       completionHandler:(nullable IVMsgDataCallback)completionHandler;


#pragma mark - 离线推送

/// 注册SDK离线推送
/// @param pushId 推送ID 如极光推送的`registrationID`
/// @param appId 从官网获取 的 appId
- (void)registerRemoteNotificationsWithPushId:(NSString *)pushId
                                        appId:(NSString *)appId
                            completionHandler:(nullable IVMsgJSONCallback)completionHandler;

/// 注册SDK离线推送
/// @param pushId 推送ID 如极光推送的`registrationID`
/// @param language 推送语言（默认中文zh_cn）
/// @param zone 时区秒 （默认设备当前时区）
/// @param appVersion app版本号
/// @param appId 从官网获取 的 appId
- (void)registerRemoteNotificationsWithPushId:(NSString *)pushId
                                     language:(nullable NSString *)language
                                     timeZone:(NSInteger)zone
                                   appVersion:(nullable NSString *)appVersion
                                        appId:(NSString *)appId
                            completionHandler:(nullable IVMsgJSONCallback)completionHandler;

/// 反注册SDK离线推送
- (void)unregisterRemoteNotification:(nullable IVMsgJSONCallback)completionHandler;

@end


NS_ASSUME_NONNULL_END
