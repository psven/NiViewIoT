//
//  IVError.h
//  IoTVideo
//
//  Created by JonorZhang on 2020/3/30.
//  Copyright © 2020 Tencentcs. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef IVError_h
#define IVError_h

/**
    ====== 平台错误码分布概览 =====
    @li [8000-8499]      Asrv错误码
    @li [8500-8699]      Csrv错误码(对接Asrv)
    @li [8799-9999]       预留
    @li [10000-10999]   通用错误码
    @li [11000-11999]   产品/设备相关
    @li [12000-12999]   用户相关
    @li [13000-13999]   客户相关
    @li [14000-14999]   云存相关
    @li [15000-15999]   UPG相关
    @li [16000-16999]   帮助中心
    @li [17000-17999]    第三方调用
    @li [20000-20150]    P2P错误码
    @li [20151-20199]   客户自定义错误
    @li [20200-20999]    P2P错误码
 👉  @li   [21000-21999]    iOS SDK错误  👈
    @li [22000-22999]   Android SDK错误码
    @li [23000-23999]   PC SDK错误码
    @li [24000-24999]   DEV SDK错误码
 */


/// [21000-21999]   iOS SDK错误
typedef NSUInteger IVErrCode;

/// 不属于[21000-21999] 范围的原因码
typedef NSUInteger IVReasonCode;


/// 常见服务器错误码 [8000-8499]
typedef NS_ENUM(IVReasonCode, IVASrvErr) {
    IVASrvErr_dst_offline                   = 8000, //!< 目标离线
    IVASrvErr_dst_notexsit                  = 8002, //!< 目标不存在
    IVASrvErr_dst_error_relation            = 8003, //!< 非法关系链（如: 用户未绑定此设备）
    IVASrvErr_binderror_dev_usr_has_bind    = 8022, //!< 设备已经绑定此用户
    IVASrvErr_binderror_dev_has_bind_other  = 8023, //!< 设备已经绑定其他用户
    IVASrvErr_binderror_customer_diffrent   = 8024, //!< 设备的客户ID与用户的客户ID不一致
};

/// P2P错误码 [20000-20999]
typedef NS_ENUM(IVReasonCode, IVTermErr) {
    //!< 终端使用
    IVTermErr_msg_send_peer_timeout          = 20001, //!< 消息发送给对方超时
    //calling相关
    IVTermErr_msg_calling_dev_hangup         = 20002, //!< 普通挂断，即设备端主动断开，APP可尝试重连
    IVTermErr_msg_calling_send_timeout       = 20003, //!< calling消息发送超时
    IVTermErr_msg_calling_no_srv_addr        = 20004, //!< 服务器未分配转发地址，APP可尝试重连
    IVTermErr_msg_calling_handshake_timeout  = 20005, //!< 握手超时，APP可尝试重连
    IVTermErr_msg_calling_token_error        = 20006, //!< 设备端token校验失败
    IVTermErr_msg_calling_all_chn_busy       = 20007, //!< 监控通道数满
    IVTermErr_msg_calling_timeout_disconnect = 20008, //!< 超时断开，APP可尝试重连
    IVTermErr_msg_calling_no_find_dst_id     = 20009, //!< 未找到目的id
    IVTermErr_msg_calling_check_token_error  = 20010, //!< token校验出错
    IVTermErr_msg_calling_dev_is_disable     = 20011, //!< 设备已经禁用
    IVTermErr_msg_calling_duplicate_call     = 20012, //!< 重复呼叫
    IVTermErr_msg_calling_caller_hungup      = 20013, //!< 连接过程中主动断开
    IVTermErr_msg_calling_relation_modify    = 20014, //!< 关系链变更导致的断开
    IVTermErr_msg_access_lib_not_init        = 20015, //!< 接入库未初始化
    IVTermErr_msg_lan_calling_not_allow      = 20016, //!< 纯局域网下密码错误或者未进行密码校验
    IVTermErr_msg_calling_no_relation        = 20017, //!< APP与设备不存在关系链
    IVTermErr_msg_calling_no_online          = 20018, //!< APP还没上线，稍后再试

    //物模型
    IVTermErr_msg_gdm_handle_processing       = 20100, //!< 设备正在处理中
    IVTermErr_msg_gdm_handle_leaf_path_error  = 20101, //!< 设备端校验叶子路径非法
    IVTermErr_msg_gdm_handle_parse_json_fail  = 20102, //!< 设备端解析JSON出错
    IVTermErr_msg_gdm_handle_fail             = 20103, //!< 设备处理ACtion失败
    IVTermErr_msg_gdm_handle_no_cb_registered = 20104, //!< 设备未注册相应的ACtion回调函数
    IVTermErr_msg_gdm_handle_buildin_prowritable_error = 20105,//!< 设备不允许通过局域网修改内置可写对象

    IVTermErr_msg_saas_hungup_code_invalid    = 20135, //!< 设备saas层挂断但是错误码给的超过范围

    //录像文件相关错误
    IVTermErr_msg_wait_option_timeout_hangup  = 20136, //!< 下载文件过程中，设备SDK等待新的操作超时导致挂断
    IVTermErr_msg_find_record_file_fail       = 20137, //!< 查找指定的回放文件失败导致播放失败，存储介质被移除、录像文件不存在，无法打开
    IVTermErr_msg_read_record_file_fail       = 20138, //!< 读取指定的回放文件失败导致播放失败, 中途被移除、无视频帧文件不合法、不可读、内存申请失败

    //user cmd 错误返回
    IVTermErr_msg_user_cmd_internal_error     = 20140, //!< 设备端内部处理错误
    IVTermErr_msg_user_cmd_type_error         = 20141, //!< 不支持的 user cmd 类型
    IVTermErr_msg_user_cmd_version_error      = 20142, //!< 不支持的 user cmd 版本
    IVTermErr_msg_user_cmd_param_error        = 20143, //!< user cmd 参数超出范围
    IVTermErr_msg_user_cmd_option_mismatch    = 20145, //!< 操作和状态不匹配，比如对讲已经开启但是又开启
    IVTermErr_msg_user_cmd_saas_err_invalid   = 20146, //!< saas层返回的错误码超过范围
};

/// iOS消息管理错误码 [21000-21019]
typedef NS_ENUM(IVErrCode, IVMessageError) {
    /// 消息重复、消息正在发送
    IVMessageError_duplicate        = 21000,
    /// 消息发送失败
    IVMessageError_sendFailed       = 21001,
    /// 消息响应超时
    IVMessageError_timeout          = 21002,
    /// 获取物模型失败
    IVMessageError_GetGdmDataErr    = 21003,
    /// 接收物模型失败
    IVMessageError_RcvGdmDataErr    = 21004,
    /// 透传数据给服务器失败
    IVMessageError_SendPassSrvErr   = 21005,
    /// 透传数据给设备失败
    IVMessageError_SendPassDevErr   = 21006,
    /// 没有找到回调
    IVMessageError_NotFoundCallback = 21007,
    /// 信令数据长度超出上限， @c `MAX_DATA_SIZE`
    IVMessageError_ExceedsMaxLength = 21008,
};

/// iOS连接错误 [21020-21029]
typedef NS_ENUM(IVErrCode, IVConnError) {
    /// APP端通道连接数已达上限, 见`MAX_CONNECTION_NUM`
    IVConnError_ExceedsMaxNumber  = 21020,
    /// 重复的连接通道(同一台设备仅允许同时建立一个播放器连接)，即目标设备的连接通道已被其他播放器对象占用
    IVConnError_Duplicate         = 21021,
    /// 建立连接失败
    IVConnError_ConnectFailed     = 21022,
    /// 连接已断开/连接失败
    IVConnError_Disconnected      = 21023,
    /// 用户自定义数据长度超出上限 @c `MAX_PKG_BYTES`
    IVConnError_ExceedsMaxLength  = 21024,
    /// 当前连接暂不可用
    IVConnError_NotAvailableNow   = 21025,
    /// 发送用户数据失败
    IVConnError_SendDataFailed    = 21026,
};

/// iOS播放器错误码 [21030-21049]
typedef NS_ENUM(IVErrCode, IVPlayerError) {
    /// 方法选择器无响应、未实现协议方法
    IVPlayerError_NoRespondsToSelector     = 21030,
    /// 参数错误
    IVPlayerError_InvalidParameter         = 21031,
    /// 录像列表为空
    IVPlayerError_PlaybackListEmpty        = 21032,
    /// 录像列表数据异常
    IVPlayerError_PlaybackDataErr          = 21033,
    /// APP正在录制音视频流
    IVPlayerError_RecorderIsRunning        = 21034,
    /// 视频分辨率已改变
    IVPlayerError_VideoResolutionChanged   = 21035,
    /// 编码器暂不可用
    IVPlayerError_EncoderNotAvailableNow   = 21036,
    /// 不支持的录像列表版本
    IVPlayerError_PlaybackListVerErr       = 21037,
    /// 设备端操作失败
    IVPlayerError_DeviceOperationFailed    = 21038,
    /// 录制器暂不可用
    IVPlayerError_RecorderNotAvailableNow  = 21039,
    /// 当前状态下不允许该操作
    IVPlayerError_OperationNotAllowedNow   = 21040,
    /// 音视频信息相关参数异常
    IVPlayerError_AVInformationAbnormal    = 21041,
};

/// iOS下载错误码 [21060-21079]
typedef NS_ENUM(IVErrCode, IVDownloadError) {
    /// 下载器正忙，若要下载其他文件，请先暂停当前任务
    IVDownloadError_DownloaderBusy    = 21060,
    /// 文件读取失败，文件被删除、存储设备拔出
    IVDownloadError_FileUnavailable   = 21061,
    /// 断点续传offset大于文件大小fileSize
    IVDownloadError_IncorrectOffset   = 21062,
    /// 打开文件失败，文件权限、文件被删除、存储设备拔出
    IVDownloadError_FileOpenFailed    = 21063,
    /// 找不到文件，文件被删除，存储设备拔出
    IVDownloadError_FileNotFound      = 21064,
    /// 设备程序/模块退出、无法继续传输
    IVDownloadError_ProcessExited     = 21065,
    /// 接收的数据大小不等于文件总大小
    IVDownloadError_DataSizeAbnormal  = 21070,
    /// 设备端发生未知错误
    IVDownloadError_DevUnknownError   = 21071,
    /// 设备端无响应（如固件版本未支持下载，网络故障、程序故障）
    IVDownloadError_DevNoResponse     = 21072,
};

/// iOS设备端ACK错误 [21080-21089]
typedef NS_ENUM(IVErrCode, IVAckErr) {
    IVAckErr_NotSupport         = 21080, //!< 设备端不支持该命令
    IVAckErr_ParameterErr       = 21081, //!< 设备端判定参数错误
    IVAckErr_UnknownErr         = 21082, //!< 设备端发生未知错误
    IVAckErr_NoResponse         = 21083, //!< 设备端无响应(如固件版本未支持，网络故障、程序故障)
    IVAckErr_DeviceBusy         = 21084, //!< 设备端正在处理指令，不接受新的指令
};

/// iOS配网错误码  [21100-21119]
typedef NS_ENUM(IVErrCode, IVNetCfgErr) {
    IVNetCfgErr_GetTokenErr     = 21100, // 获取Token失败
    IVNetCfgErr_TokenExpired    = 21101, // Token已过期
    IVNetCfgErr_DevStatusErr    = 21102, // 设备非可绑定状态
    IVNetCfgErr_ServerErr       = 21103, // 服务器报错
};

/// iOS删除文件错误码  [21120-21139]
typedef NS_ENUM(IVErrCode, IVFileDelErr){
    /// 删除成功
    IVFileDelErr_Success           = 21120,
    /// 设备端存储异常：索引文件不存在(无法打开)、录像文件无法删除，可能的原因：存储设备被拔除、无访问权限等
    IVFileDelErr_StroageExcept     = 21121,
    /// 设备端资源不足：申请内存失败、分配资源失败，可能的原因：内存不足，待删除的文件数目过多
    IVFileDelErr_ResourcesLack     = 21122,
    /// 设备端删除失败：删除异常，执行remove
    IVFileDelErr_DefaultCode       = 21123,
    /// 设备端删除失败：请求删除的文件不在记录列表里->无法删除
    IVFileDelErr_InfoNotExist      = 21124,
    /// 设备端资源正忙无法执行该操作：正在回放、正在下载、正在删除时无法执行删除命令
    IVFileDelErr_ResourcesBusy     = 21125,
    /// 用户侧APP主动取消了本次删除
    IVFileDelErr_AppCancel         = 21126,
};

extern NSString *IVErrorDescribe(IVErrCode errorCode);

extern NSError  *IVErrorMake(id target, IVErrCode errorCode, const char *fmt, ...);
extern NSError  *IVErrorMake2(id target, IVErrCode errorCode, IVReasonCode reasonCode, const char *fmt, ...);
extern NSError  *IVErrorMake3(id target, IVErrCode errorCode, IVReasonCode reasonCode, const char *reasonDesc, const char *fmt, ...);


#endif /* IVError_h */
