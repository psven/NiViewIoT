//
//  NIotMessageMgr.swift
//  NIot
//
//  Created by apple on 2021/11/16.
//

import UIKit
import IoTVideo

@objc
public protocol NIotMessageDelegate {
    /// 接收到事件消息（Event）:  告警、分享、系统通知
    /// - Parameters:
    ///   - event: 事件消息体
    ///   - topic:  请参照物模型定义
    @objc optional func didReceiveEvent(_ event: String, topic: String)
    
    /// 接收到只读属性消息（ProReadonly.xxx.stVal / Action.xxx.stVal）
    /// - Parameters:
    ///   - json: 内容（JSON的具体字符串）
    ///   - path:  路径（JSON的叶子节点）
    ///   - deviceId: 设备ID
    @objc optional func didUpdateProperty(_ json: String, path: String, deviceId: String)
    
    /// 接收到设备发起的透传数据
    /// - Parameters:
    ///   - data: 数据
    ///   - deviceId: 设备ID
    @objc optional func didReceivePassthroughData(_ data: Data, deviceId: String)
}

private class IVMessageDelegateProxy: NSObject, IVMessageDelegate {
    
    weak var delegate: NIotMessageDelegate?
    
    func didReceiveEvent(_ event: String, topic: String) {
        delegate?.didReceiveEvent?(event, topic: topic)
    }
    
    func didUpdateProperty(_ json: String, path: String, deviceId: String) {
        delegate?.didUpdateProperty?(json, path: path, deviceId: deviceId)
    }
    
    func didReceivePassthroughData(_ data: Data, deviceId: String) {
        delegate?.didReceivePassthroughData?(data, deviceId: deviceId)
    }
}

@objcMembers
open class NIotMessageMgr: NSObject {
    
    public typealias CompletionHandler = (_ json: String?, _ error: Error?) -> Void
    public typealias DataResponse = (_ data: Data?, _ error: Error?) -> Void
    public typealias LinkStatusCallback = (_ status: Int) -> Void
    public typealias PlaybackListCallback = (NIotPlaybackPage?, Error?) -> Void
    
    @objc(sharedInstance)
    public static let shared = NIotMessageMgr()
    public weak var delegate: NIotMessageDelegate? {
        didSet {
            messageMgr.delegate = delegateProxy
            delegateProxy.delegate = delegate
        }
    }
    
    private let delegateProxy = IVMessageDelegateProxy()
    private let messageMgr = IVMessageMgr.sharedInstance
}

// MARK: - 读写
extension NIotMessageMgr {
    
    /// 获取设备物模型属性
    /// - Parameters:
    ///   - tid: 设备ID
    ///   - path: 路径（JSON的叶子节点）
    ///   - completionHandler: 回调
    open func readPropertyOfDevice(tid: String, path: String, completionHandler: CompletionHandler? = nil) {
        messageMgr.readProperty(ofDevice: tid, path: path, completionHandler: completionHandler)
    }
    
    /// 设置设备物模型属性
    /// - Parameters:
    ///   - tid: 设备ID
    ///   - path: 路径（JSON的叶子节点）
    ///   - json: 内容（JSON的具体字符串）
    ///   - completionHandler: 回调
    open func writePropertyOfDevice(tid: String, path: String, json: String, completionHandler: CompletionHandler? = nil) {
        messageMgr.writeProperty(ofDevice: tid, path: path, json: json, completionHandler: completionHandler)
    }
    
    
}

// MARK: - 信令数据透传
extension NIotMessageMgr {
    
    /// 信令数据透传给设备（单次数据回传）
    ///
    /// 不需要建立通道连接，数据经由服务器转发，适用于实时性不高、数据小于`MAX_DATA_SIZE`、需要回传的场景，如获取信息。
    /// - note: 完成回调条件：收到ACK错误、消息超时 或 有数据回传
    /// - Parameters:
    ///   - tid: 设备ID
    ///   - data: 数据内容，data.length不能超过`MAX_DATA_SIZE`
    ///   - response: 回调
    open func sendDataToDevice(tid: String, data: String, with response: DataResponse? = nil) {
        guard let data = data.data(using: .utf8) else {
            return
        }
        messageMgr.sendData(toDevice: tid, data: data, withResponse:response)
    }
     
}

// MARK: - SD Card
extension NIotMessageMgr {
    
    /// 格式化TF卡，格式化结果通过物模型监听 storage.stVal.state 判断，详情查看 文档-物模型 说明
    /// - Parameters:
    ///   - tid: 设备 id
    ///   - completionHandler: 回调
    open func formatTFCardOfDevice(tid: String, completionHandler: CompletionHandler? = nil) {
        messageMgr.takeAction(ofDevice: tid, path: "Action.tfFormat", json: "{\"stVal\":1}", completionHandler: completionHandler)
    }
    
    /// 获取SD卡录像日历打点
    /// - Parameters:
    ///   - tid: 设备 id
    ///   - pageIndex: page index
    ///   - countPerPage: 每页数量
    ///   - startTime: 开始时间，毫秒
    ///   - endTime: 结束时间，毫秒
    ///   - completionHandler: 回调
    open func getSDRecordDateList(tid: String, pageIndex: UInt32, countPerPage: UInt32, startTime: TimeInterval, endTime: TimeInterval, completionHandler: @escaping PlaybackListCallback) {
        IVPlaybackPlayer.getDateList(ofDevice: tid, pageIndex: pageIndex, countPerPage: countPerPage, startTime: startTime, endTime: endTime) { (playbackPage, error) in
            
            guard let items = playbackPage?.items, !items.isEmpty, error == nil else {
                completionHandler(nil, error)
                return
            }
            
            let page = NIotPlaybackPage.init(
                pageIndex: playbackPage?.pageIndex ?? 0,
                totalPage: playbackPage?.totalPage ?? 0,
                items: items
            )
            completionHandler(page, error)
        }
    }
    
    /// 获取SD卡录像列表
    /// - Parameters:
    ///   - tid: 设备 id
    ///   - pageIndex: page index
    ///   - countPerPage: 每页数量
    ///   - startTime: 开始时间，毫秒
    ///   - endTime: 结束时间，毫秒
    ///   - filterType: 录像类型（””：全部；”pir”：移动侦测；”key”：按键唤醒；”live”：主动唤醒；”alltime”：全时录像）
    ///   - completionHandler: 回调
    open func getSDPlaybackList(tid: String, pageIndex: UInt32, countPerPage: UInt32, startTime: TimeInterval, endTime: TimeInterval, filterType: String, completionHandler: @escaping PlaybackListCallback) {
        IVPlaybackPlayer.getPlaybackList(ofDevice: tid, pageIndex: pageIndex, countPerPage: countPerPage, startTime: startTime, endTime: endTime, filterType: filterType, ascendingOrder: true) { (playbackPage, error) in
            guard let items = playbackPage?.items, !items.isEmpty, error == nil else {
                completionHandler(nil, error)
                return
            }
            
            let page = NIotPlaybackPage.init(
                pageIndex: playbackPage?.pageIndex ?? 0,
                totalPage: playbackPage?.totalPage ?? 0,
                items: items
            )
            completionHandler(page, error)
        }
    }
     
}


// MARK: - Device
extension NIotMessageMgr {
    
    /// 获取设备最新版本
    /// - Parameters:
    ///   - tid: 设备 id
    ///   - currentOTAVersion: 设备当前版本
    ///   - completionHandler: 回调
    open func getDeviceNewVersion(tid: String, currentOTAVersion: String, completionHandler: @escaping CompletionHandler) {
        IVDeviceMgr.queryDeviceNewVersionWidthDevieId(tid, currentVersion: currentOTAVersion, language: nil, responseHandler: completionHandler)
    }
    
    /// 设备升级
    ///
    /// - note: 设备升级需要先唤醒设备，设备升级进度超时建议不小于5分钟，格式化结果通过物模型监听 Action.doUpgrade 判断，详情查看 文档-物模型 说明
    /// - Parameters:
    ///   - tid: 设备 id
    ///   - completionHandler: 回调
    open func upgradeDevice(tid: String, completionHandler: @escaping CompletionHandler) {
        IVMessageMgr.sharedInstance.takeAction(ofDevice: tid, path: "Action._otaVersion", json: "{\"stVal\":\"\"}") { (json, error) in
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            IVMessageMgr.sharedInstance.takeAction(ofDevice: tid, path: "Action._otaUpgrade", json: "{\"stVal\":1}", completionHandler: completionHandler)
        }
    }
}
