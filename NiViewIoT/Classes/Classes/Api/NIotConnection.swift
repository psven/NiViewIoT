//
//  NIotConnection.swift
//  NIot
//
//  Created by apple on 2021/11/25.
//

import UIKit
import IoTVideo

@objc
public enum NIotConnType: UInt {
    case live = 0
    case fileDownload = 6
    case thumbDownload = 7
}

@objc
public enum NIotConnStatus: Int {
    case disconnecting = -1
    case disconnected = 0
    case connecting = 1
    case connected = 2
}

/// 连接过程子状态
/// - note:  部分设备/场景是没有子状态的
@objc
public enum NIotConnSubstate: Int {
    /// 服务器已收到连接请求，正在唤醒设备
    case wakingUpDev = 1
    /// 设备已收到唤醒通知，开始握手过程
    case handshaking = 2
    /// 握手过程完成，连接通道已就绪
    case connectReady = 3
}


@objc
public protocol NIotConnectionDelegate {
    /// 状态更新
    /// - Parameters:
    ///   - connection: 连接实例
    ///   - status: 状态
    @objc optional func connection(_ connection: NIotConnection, didUpdateStatus status: NIotConnStatus)
    
    /// 连接过程子状态更新
    /// - note:  部分设备/场景是没有子状态的
    /// - Parameters:
    ///   - connection: 连接实例
    ///   - substate: 连接过程子状态
    @objc optional func connection(_ connection: NIotConnection, didUpdateSubstate substate: NIotConnSubstate)
    
    /// 数据接收速率
    /// - Parameters:
    ///   - connection: 连接实例
    ///   - speed: 接收速率(字节/秒)
    @objc optional func connection(_ connection: NIotConnection, didUpdateSpeed speed: UInt32)
    
    /// 收到错误
    /// - Parameters:
    ///   - connection: 连接实例
    ///   - error: 错误
    @objc optional func connection(_ connection: NIotConnection, didReceiveError error: Error)
    
    /// 收到数据
    /// - Parameters:
    ///   - connection: 连接实例
    ///   - data: 数据
    @objc optional func connection(_ connection: NIotConnection, didReceiveData data: Data)
}
 
class IoTConnectionDelegateProxy: NSObject, IVConnectionDelegate {
    
    unowned var _connection: NIotConnection
    weak var connDelegate: NIotConnectionDelegate?
    
    init(connection: NIotConnection) {
        _connection = connection
    }
     
    
    // MARK: - Connection
    func connection(_ connection: IVConnection, didUpdate status: IVConnStatus) {
        guard let status = NIotConnStatus(rawValue: status.rawValue) else {
            return
        }
        connDelegate?.connection?(_connection, didUpdateStatus: status)
    }
    
    func connection(_ connection: IVConnection, didUpdate substate: IVConnectingSubstate) {
        guard let substate = NIotConnSubstate(rawValue: substate.rawValue) else {
            return
        }
        connDelegate?.connection?(_connection, didUpdateSubstate: substate)
    }
    
    func connection(_ connection: IVConnection, didUpdateSpeed speed: UInt32) {
        connDelegate?.connection?(_connection, didUpdateSpeed: speed)
    }
    
    func connection(_ connection: IVConnection, didReceiveError error: Error) {
        connDelegate?.connection?(_connection, didReceiveError: error)
    }
    
    func connection(_ connection: IVConnection, didReceive data: Data) {
        connDelegate?.connection?(_connection, didReceiveData: data)
    }
}


/// Abstract class
@objcMembers
open class NIotConnection: NSObject {
    
    var _connection: IVConnection?
    
    public weak var connDelegate: NIotConnectionDelegate? {
        didSet {
            _connection?.delegate = delegateProxy
            delegateProxy.connDelegate = connDelegate
        }
    }
    
    private var delegateProxy: IoTConnectionDelegateProxy!
    
    override init() {
        super.init()
        defer {
            delegateProxy = IoTConnectionDelegateProxy(connection: self)
        }
    }
     
}

extension NIotConnection {
    /// 设备ID
    open var deviceId: String? { _connection?.deviceId }
    /// 源ID（一个设备 可以对应 多个源），默认为0
    open var sourceId: UInt16? { _connection?.sourceId }
    /// 通道ID，连接成功该值才有效（一个设备+一个源 对应 唯一通道），无效值为-1
    open var channel: UInt32? { _connection?.channel }
    /// 连接类型
    open var connType: NIotConnType? {
        guard let connection = _connection else { return nil }
        return NIotConnType(rawValue: connection.connType.rawValue)
    }
    /// 连接状态
    open var connStatus: NIotConnStatus? {
        guard let connection = _connection else { return nil }
        return NIotConnStatus(rawValue: connection.connStatus.rawValue) }
}
