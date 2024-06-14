//
//  NIotLivePlayer.swift
//  NIot
//
//  Created by apple on 2021/11/23.
//

import UIKit
import IoTVideo
 
// IVPlayer 封装，分辨率缓存封装
// DeviceModel 封装
// IVFileDownloader 封装，IVDownloadItem 不封装

/// 监控播放器
@objcMembers
open class NIotMonitorPlayer: NIotPlayer {
    
    private var _monitorPlayer: IVMonitorPlayer! {
        get { _player as? IVMonitorPlayer }
        set { _player = newValue }
    }
    
    /// 创建播放器
    /// - Parameters:
    ///   - deviceId: 设备ID
    ///   - sourceId: 源ID，默认为0
    required public init?(deviceId: String, sourceId: UInt16 = 0) {
        guard let player = IVMonitorPlayer(deviceId: deviceId, sourceId: sourceId) else {
            return nil
        }
        super.init()
        _monitorPlayer = player
    }
     
}

extension NIotMonitorPlayer {
    /// 当前与设备对讲的客户端数量
    open var talkerNum: UInt { _monitorPlayer.talkerNum }
    /// 是否正在对讲
    open var isTalking: Bool { _monitorPlayer.isTalking }
}

extension NIotMonitorPlayer {
      
    /// 开启对讲
    open func startTalking() {
        _monitorPlayer.startTalking()
    }
     
    /// 开启对讲
    open func startTalking(completionHandler: NIotSettingCallback?) {
        _monitorPlayer.startTalking(completionHandler)
    }
    
    /// 结束对讲
    open func stopTalking() {
        _monitorPlayer.stopTalking()
    }
     
    /// 结束对讲
    open func stopTalking(completionHandler: NIotSettingCallback?) {
        _monitorPlayer.stopTalking(completionHandler)
    }
}
