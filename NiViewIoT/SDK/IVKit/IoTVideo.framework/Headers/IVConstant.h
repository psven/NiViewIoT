//
//  IVConstant.h
//  IoTVideo
//
//  Created by JonorZhang on 2020/8/19.
//  Copyright © 2020 Tencentcs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString * IVOptionKey NS_STRING_ENUM;

/**
Web服务器域名配置：
    @li 不指定时默认为内置正式服
    @li "TEST": 内置测试服
    @li "xxxx": 自定义web服务器域名
 */
FOUNDATION_EXPORT IVOptionKey const IVOptionKeyHostWeb;

/**
 P2P服务器域名:
    @li 不指定时默认为内置正式服
    @li "TEST": 内置测试服
    @li "xxxx": 自定义P2P服务器域名
 */
FOUNDATION_EXPORT IVOptionKey const IVOptionKeyHostP2P;

/**
 使用SDK的APP的版本号
 */
FOUNDATION_EXPORT IVOptionKey const IVOptionKeyAppVersion;

/**
 使用SDK的APP的包名
 */
FOUNDATION_EXPORT IVOptionKey const IVOptionKeyAppPkgName;

/**
 使用SDK的APP的语言
 */
FOUNDATION_EXPORT IVOptionKey const IVOptionKeyAppLanguage;

/**
 使用SDK的APP_ID
 */
FOUNDATION_EXPORT IVOptionKey const IVOptionKeyAppID;

/**
 使用SDK的APP_Token
 */
FOUNDATION_EXPORT IVOptionKey const IVOptionKeyAppToken;

/**
 使用SDK的设备类型 保留
 */
FOUNDATION_EXPORT IVOptionKey const IVOptionKeyAppDevType;

/**
 APP PushID
 */
FOUNDATION_EXPORT IVOptionKey const IVOptionKeyPushID;

/**
 第三方ID前缀 保留
 */
FOUNDATION_EXPORT NSString *  const IVThirdIDPrefix;



/// SDK与服务器的连接状态
typedef NS_ENUM(int, IVLinkStatus) {
    /// 注销中...
    IVLinkStatusUnregistering    = -1,
    /// 注册中...
    IVLinkStatusRegistering      = 0,
    /// 在线
    IVLinkStatusOnline           = 1,
    /// 离线
    IVLinkStatusOffline          = 2,
    /// accessToken校验失败
    IVLinkStatusTokenFailed      = 3,
    /// 账号被踢飞/在别处登陆
    IVLinkStatusKickOff          = 6,
    /// 设备重复激活，无法使用
    IVLinkStatusDevReactived     = 12,
    /// APP注册accessToken过期，需要注销SDK后重新注册
    IVLinkStatusTokenExpired     = 13,
    /// APP注册accessToken解密失败，需要注销SDK后重新注册
    IVLinkStatusTokenDecryptFail = 14,
    /// APP注册accessToken校验和失败，需要注销SDK后重新注册
    IVLinkStatusTokenChkvalErr   = 15,
    /// APP注册accessToken比较失败，需要注销SDK后重新注册
    IVLinkStatusTokenCmpFail     = 16,
    /// APP注册accessId异常，需要注销SDK后重新注册
    IVLinkStatusTermidInvalid    = 17,
};

extern const NSString *linkStatusDesc(IVLinkStatus status);

/// 校验/修改局域网设备密码返回值
typedef NS_ENUM(NSUInteger, IVLANPwdResult) {
    IVLANPwdResultNull             = 0,//!< 无密码
    IVLANPwdResultCheckSuccess     = 1,//!< 密码校验成功
    IVLANPwdResultCheckFail        = 2,//!< 密码校验失败
    IVLANPwdResultModifySuccess    = 3,//!< 密码修改成功
    IVLANPwdResultModifyFail       = 4,//!< 密码修改失败
    IVLANPwdResultAccessForbiden   = 5,//!< 设备端禁止纯局域网连接
    IVLANPwdResultTimeOut          = 6,//!< 超时
    IVLANPwdResultDeviceUnrealized = 7,//!< 设备端未实现密码校验处理函数
};

/// 语言码
typedef NS_ENUM(NSUInteger, IVLanguageCode) {
    IVLanguageCodeEN = 1,  /**< 英文*/
    IVLanguageCodeCN = 2,  /**< 中文简体*/
    IVLanguageCodeTH = 3,  /**< 泰语*/
    IVLanguageCodeVI = 4,  /**< 越南语*/
    IVLanguageCodeDE = 5,  /**< 德语*/
    IVLanguageCodeKO = 6,  /**< 韩语*/
    IVLanguageCodeFR = 7,  /**< 法语*/
    IVLanguageCodePT = 8,  /**< 葡萄牙语*/
    IVLanguageCodeIT = 9,  /**< 意大利语*/
    IVLanguageCodeRU = 10, /**< 俄语*/
    IVLanguageCodeJA = 11, /**< 日语*/
    IVLanguageCodeES = 12, /**< 西班牙语*/
    IVLanguageCodePL = 13, /**< 波兰语*/
    IVLanguageCodeTR = 14, /**< 土耳其语*/
    IVLanguageCodeFA = 15, /**< 波斯语*/
    IVLanguageCodeID = 16, /**< 印尼语*/
    IVLanguageCodeMS = 17, /**< 马来语*/
    IVLanguageCodeCS = 18, /**< 捷克语*/
    IVLanguageCodeSK = 19, /**< 斯洛伐克语*/
    IVLanguageCodeNL = 20, /**< 荷兰语*/
    IVLanguageCodeTC = 21, /**< 中文繁体*/
    IVLanguageCodeGR = 22, /**< 希腊语*/
};

/// 当前手机系统使用的语言码
extern IVLanguageCode getSystemLanguageCode(void);

NS_ASSUME_NONNULL_END
