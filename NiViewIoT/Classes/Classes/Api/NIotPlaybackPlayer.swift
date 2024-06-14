//
//  NIotPlaybackPlayer.swift
//  NIot
//
//  Created by apple on 2021/11/23.
//

import UIKit
import IoTVideo



/// 回放文件切换策略
@objc
public enum NIotPlaybackStrategy: UInt {
    /// 按文件开始时间从小到大（升序）自动播放，默认值
    case ascending = 0
    /// 按文件开始时间从大到小（降序）自动播放
    case descending = 1
    /// 播放单个文件，播完自动暂停
    case single = 2
}

/// 回放播放器
@objcMembers
open class NIotPlaybackPlayer: NIotPlayer {
    
    private var _playbackPlayer: IVPlaybackPlayer! {
        get { _player as? IVPlaybackPlayer }
        set { _player = newValue }
    }
    
    /// 创建播放器
    /// - Parameters:
    ///   - deviceId: 设备ID
    public init?(deviceId: String) {
        guard let player = IVPlaybackPlayer(deviceId: deviceId) else {
            return nil
        }
        super.init()
        _playbackPlayer = player
    }
    
    /// 创建播放器
    /// - Parameters:
    ///   - deviceId: 设备ID
    ///   - sourceId: 源ID，默认为0
    public init?(deviceId: String, sourceId: UInt16) {
        guard let player = IVPlaybackPlayer(deviceId: deviceId, sourceId: sourceId) else {
            return nil
        }
        super.init()
        _playbackPlayer = player
    }
    
    /// 创建播放器
    /// - Parameters:
    ///   - deviceId: 设备ID
    ///   - playbackItem: 播放的文件(可跨文件)
    ///   - seekToTime: 指定播放起始时间点（秒），取值范围`playbackItem.startTime >= time <= playbackItem.endTime`
    public init?(deviceId: String, playbackItem: NIotPlaybackItem, seekToTime: TimeInterval) {
        let pbItem = IVPlaybackItem(niPBItem: playbackItem)
        guard let player = IVPlaybackPlayer(deviceId: deviceId, sourceId: 0, playbackItem: pbItem, seekToTime: seekToTime) else {
            return nil
        }
        super.init()
        _playbackPlayer = player
    }
     
    /// 创建播放器
    /// - Parameters:
    ///   - deviceId: 设备ID
    ///   - sourceId: 源ID，默认为0
    ///   - playbackItem: 播放的文件(可跨文件)
    ///   - seekToTime: 指定播放起始时间点（秒），取值范围`playbackItem.startTime >= time <= playbackItem.endTime`
    public init?(deviceId: String, sourceId: UInt16, playbackItem: NIotPlaybackItem, seekToTime: TimeInterval) {
        let pbItem = IVPlaybackItem(niPBItem: playbackItem)
        guard let player = IVPlaybackPlayer(deviceId: deviceId, sourceId: sourceId, playbackItem: pbItem, seekToTime: seekToTime) else {
            return nil
        }
        super.init()
        _playbackPlayer = player
    } 
    
    /// 回放策略，默认 ascending
    open var playbackStrategy: NIotPlaybackStrategy = .ascending {
        didSet {
            guard let ivStrategy = IVPlaybackStrategy(rawValue: playbackStrategy.rawValue) else { return }
            _playbackPlayer.playbackStrategy = ivStrategy
        }
    }
    
    ///  设置回放策略
    open func setPlaybackStrategy(_ strategy: NIotPlaybackStrategy, completionHandler: NIotSettingCallback?) {
        guard let ivStrategy = IVPlaybackStrategy(rawValue: strategy.rawValue) else { return }
        _playbackPlayer.setPlaybackStrategy(ivStrategy, completionHandler: completionHandler)
    }
    
    /// 回放倍速
    ///
    /// 默认1.0, 一般取值范围[0.5~16.0], SDK允许传参范围(0.0~32.0]，开发者应视设备性能而定!
    /// - note:  超过2倍速后设备是不会发音频的，并且视频只有关键帧
    open var playbackSpeed: Float = 1.0 {
        didSet {
            _playbackPlayer.playbackSpeed = playbackSpeed
        }
    }
    
    /// 设置回放倍速
    open func setPlayerSpeed(_ speed: Float, completionHandler: NIotSettingCallback?) {
        _playbackPlayer.setPlaybackSpeed(speed, completionHandler: completionHandler)
    }
     
}

extension NIotPlaybackPlayer {
    /// 当前回放的文件。
    /// - note: 当前回放时间通过`-[NIotPlayer pts]`获取
    open var playbackItem: NIotPlaybackItem? {
        guard let item = _playbackPlayer.playbackItem else {
            return nil
        }
        return NIotPlaybackItem(ivPBItem: item)
    }
}

extension NIotPlaybackPlayer {
    
    /// (未播放前)设置回放参数.
    /// - note:  应在文件尚未播放时使用，需手动调用`play`开始播放.
    /// - Parameters:
    ///   - item: 播放的文件(可跨文件).
    ///   - seekToTime: 指定播放起始时间点（秒），取值范围`playbackItem.startTime >= time <= playbackItem.endTime`.
    open func setPlaybackItem(_ item: NIotPlaybackItem, seekToTime: TimeInterval) {
        _playbackPlayer.setPlaybackItem(IVPlaybackItem(niPBItem: item), seekToTime: seekToTime)
    }
    
    /// (已播放后)跳到指定文件和时间播放
    /// - note:  应在文件正在播放时使用，无需再手动调用`play`开始播放.
    /// - Parameters:
    ///   - time: 指定播放起始时间点（秒），取值范围`playbackItem.startTime >= time <= playbackItem.endTime`
    ///   - playbackItem: 播放的文件(可跨文件)
    open func seek(toTime time: TimeInterval, playbackItem: NIotPlaybackItem) {
        _playbackPlayer.seek(toTime: time, playbackItem: IVPlaybackItem(niPBItem: playbackItem))
    }
    
    /// (已播放后)跳到指定文件和时间播放
    /// - note:  应在文件正在播放时使用，无需再手动调用`play`开始播放.
    /// - Parameters:
    ///   - time: 指定播放起始时间点（秒），取值范围`playbackItem.startTime >= time <= playbackItem.endTime`
    ///   - playbackItem: 播放的文件(可跨文件)
    ///   - completionHandler: 回调
    open func seek(toTime time: TimeInterval, playbackItem: NIotPlaybackItem, completionHandler: NIotSettingCallback?) {
        _playbackPlayer.seek(toTime: time, playbackItem: IVPlaybackItem(niPBItem: playbackItem), completionHandler: completionHandler)
    }
    
    open func pause() {
        _playbackPlayer.pause()
    }
    
    open func pause(completionHandler: NIotSettingCallback?) {
        _playbackPlayer.pause(completionHandler)
    }
    
    open func resume() {
        _playbackPlayer.resume()
    }
    
    open func resume(completionHandler: NIotSettingCallback?) {
        _playbackPlayer.resume(completionHandler)
    }
}
