//
//  NIotManager.swift
//  NIot
//
//  Created by apple on 2021/11/23.
//

import UIKit
import IoTVideo
//import NIot.NIot_TIoTLinkKit_Private
//import NIot.NIot_TIoTLinkVideo_Private

@objc
public protocol NIotManagerDelegate {
    /// SDK与服务器的连接状态变更
    ///
    /// - Parameter linkStatus: SDK与服务器的连接状态
    @objc optional func didUpdate(_ linkStatus: NIotLinkStatus)
    /// 日志输出回调
    /// - Parameter message:  带格式化的日志信息
    @objc optional func didOutputPrettyLogMessage(_ message: String)
}

/// IoTVideoDelegate 事件代理
///
/// IoTVideoDelegate 属于 IoTVideo,
/// NIotManager 要想保持 open 级别访问，delegate 也跟着必须保持 open,
/// 但是 SDK 需私有化 IoTVideo，所以这里用一个代理来处理 IoTVideoDelegate 回调事件
///
/// SDK中其他写法同理
private class IoTVideoDelegateProxy: NSObject, IoTVideoDelegate {
    
    weak var delegate: NIotManagerDelegate?
    
    func didUpdate(_ linkStatus: IVLinkStatus) {
        guard let status = NIotLinkStatus(rawValue: linkStatus.rawValue) else {
            return
        }
        delegate?.didUpdate?(status)
    }

    func didOutputPrettyLogMessage(_ message: String) {
        delegate?.didOutputPrettyLogMessage?(message)
    }
}



/// SDK与服务器的连接状态
@objc
public enum NIotLinkStatus: Int32 {
    /// 注销中...
    case unregistering = -1
    /// 注册中...
    case registering = 0
    /// 在线
    case online = 1
    /// 离线
    case offline = 2
    /// accessToken校验失败
    case tokenFailed = 3
    /// 账号被踢飞/在别处登陆
    case kickOff = 6
    /// 设备重复激活，无法使用
    case devReactived = 12
    /// APP注册accessToken过期，需要注销SDK后重新注册
    case tokenExpired = 13
    /// APP注册accessToken解密失败，需要注销SDK后重新注册
    case tokenDecryptFail = 14
    /// APP注册accessToken校验和失败，需要注销SDK后重新注册
    case tokenChkvalErr = 15
    /// APP注册accessToken比较失败，需要注销SDK后重新注册
    case tokenCmpFail = 16
    /// APP注册accessId异常，需要注销SDK后重新注册
    case termidInvalid = 17
}


@objcMembers
open class NIotManager: NSObject {
     
    @objc(sharedInstance)
    public static let shared = NIotManager()
    public weak var delegate: NIotManagerDelegate? {
        didSet {
            iotVideo.delegate = delegateProxy
            delegateProxy.delegate = delegate
        }
    }
    
    public var debugMode: Bool {
        set { kISDebug = newValue }
        get { kISDebug }
    }
    
    private let delegateProxy = IoTVideoDelegateProxy()
    private let iotVideo = IoTVideo.sharedInstance
}

extension NIotManager {
    /// 访问Token
    open var accessToken: String? { iotVideo.accessToken }
    /// 用户ID（外部访问IotVideo云平台的唯一性身份标识）
    open var accessId: String? { iotVideo.accessId }
    /// 终端ID
    open var terminalId: String? { iotVideo.terminalId }
    /// SDK与服务器的连接状态
    open var linkStatus: Int32 { iotVideo.linkStatus.rawValue }
}

extension NIotManager {
    
    /// SDK初始化配置一些参数, 需要在`application:didFinishLaunchingWithOptions:`中调用
    /// - Parameter launchOptions:  传入application:didFinishLaunchingWithOptions: 得到的launchOptions
    open func setup(launchOptions: [AnyHashable: Any]?) {
        iotVideo.setup(launchOptions: launchOptions)
    }
    
    /// 注册登陆信息，建议在登录成功(获取到accessId、accessToken)后调用
    /// - Parameters:
    ///   - accessId: 注册成功后返回的用户ID，是外部访问IotVideo云平台的唯一性身份标识
    ///   - accessToken:  登录成功服务器返回的`accessToken`
    open func register(accessId: String, accessToken: String) {
        iotVideo.register(withAccessId: accessId, accessToken: accessToken)
    }
    
    /// SDK反注册，退出登录时调用
    open func unregisgter() {
        iotVideo.unregister()
    }
}
