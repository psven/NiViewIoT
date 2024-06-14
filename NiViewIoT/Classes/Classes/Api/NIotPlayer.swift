//
//  NIotPlayer.swift
//  NIot
//
//  Created by apple on 2021/11/23.
//

import UIKit
import IoTVideo


public typealias NIotSettingCallback = (Error?) -> Void

@objc
public enum NIotVideoDefinition: UInt {
    case low = 0
    case mid = 1
    case high = 2
}

@objc
public enum NIotPlayerStatus: Int {
    case stopping = -1
    case stopped = 0
    case preparing = 1
    case ready = 2
    case loading = 3
    case playing = 4
    case paused = 5
    case fastForward = 6
    case seeking = 7
}

@objc
public protocol NIotPlayerDelegate: NIotConnectionDelegate {
    
    /// 播放器状态回调
    /// - Parameters:
    ///   - player: 播放器实例
    ///   - status: 状态值
    @objc optional func player(_ player: NIotPlayer, didUpdateStatus status: NIotPlayerStatus)
    
    /// 播放时间回调
    /// - Parameters:
    ///   - player: 播放器实例
    ///   - PTS: 时间戳
    @objc optional func player(_ player: NIotPlayer, didUpdatePTS PTS: TimeInterval)
    
    /// SD卡回放文件即将播放
    /// - Parameters:
    ///   - player: 播放器实例
    ///   - fileTime: 时间戳
    @objc optional func player(_ player: NIotPlayer, willBeginOfFile fileTime: TimeInterval)
    
    /// SD卡回放文件播放结束
    /// - Parameters:
    ///   - player: 播放器实例
    ///   - fileTime: 时间戳
    @objc optional func player(_ player: NIotPlayer, didEndOfFile fileTime: TimeInterval)
    
    /// 观看人数变更
    /// - Parameters:
    ///   - player: 播放器实例
    ///   - viewerNum: 观看人数
    @objc optional func player(_ player: NIotPlayer, didUpdateViewerNum viewerNum: Int)
    
    /// 对讲人数变更
    /// - Parameters:
    ///   - player: 播放器实例
    ///   - talkerNum: 观看人数
    @objc optional func player(_ player: NIotPlayer, didUpdateTalkerNum talkerNum: Int)
    
    /// 播放错误回调
    ///
    /// 播放器捕获到的一些错误（不一定会导致播放中断），用于辅助开发者定位和发现问题，不要在此处stop()
    /// - Parameters:
    ///   - player: 播放器实例
    ///   - error: 错误实例
    @objc optional func player(_ player: NIotPlayer, didReceiveError error: Error)
}
 
class IoTPlayerDelegateProxy: IoTConnectionDelegateProxy, IVPlayerDelegate {
    
    unowned var _player: NIotPlayer
    weak var playerDelegate: NIotPlayerDelegate? {
        didSet {
            connDelegate = playerDelegate
        }
    }
    
    init(player: NIotPlayer) {
        _player = player
        super.init(connection: player)
    }
    
    func player(_ player: IVPlayer, didUpdate status: IVPlayerStatus) {
        guard let status = NIotPlayerStatus(rawValue: status.rawValue) else {
            return
        }
        playerDelegate?.player?(_player, didUpdateStatus: status)
    }
    
    func player(_ player: IVPlayer, didUpdatePTS PTS: TimeInterval) {
        playerDelegate?.player?(_player, didUpdatePTS: PTS)
    }
    
    func player(_ player: IVPlayer, willBeginOfFile fileTime: TimeInterval) {
        playerDelegate?.player?(_player, willBeginOfFile: fileTime)
    }
    
    func player(_ player: IVPlayer, didEndOfFile fileTime: TimeInterval, error: Error?) {
        playerDelegate?.player?(_player, didEndOfFile: fileTime)
    }
    
    func player(_ player: IVPlayer, didUpdateViewerNum viewerNum: Int) {
        playerDelegate?.player?(_player, didUpdateViewerNum: viewerNum)
    }
    
    func player(_ player: IVPlayer, didUpdateTalkerNum talkerNum: Int) {
        playerDelegate?.player?(_player, didUpdateTalkerNum: talkerNum)
    }
    
    func player(_ player: IVPlayer, didReceiveError error: Error) {
        playerDelegate?.player?(_player, didReceiveError: error)
    }
}

/// Abstract class
@objcMembers
open class NIotPlayer: NIotConnection {
      
    var _player: IVPlayer? {
        get { _connection as? IVPlayer }
        set { _connection = newValue }
    }
    
    public weak var delegate: NIotPlayerDelegate? {
        didSet {
            _player?.delegate = delegateProxy
            delegateProxy.playerDelegate = delegate
        }
    }
    
    private var delegateProxy: IoTPlayerDelegateProxy!
    
    override init() {
        super.init()
        defer {
            delegateProxy = IoTPlayerDelegateProxy(player: self)
        }
    }
    
    /// 视频清晰度
    open var definition: NIotVideoDefinition = .high {
        didSet {
            _player?.definition = IVVideoDefinition(rawValue: definition.rawValue) ?? .high
        }
    }
    
    /// 设置视频清晰度
    open func setDefinition(_ definition: NIotVideoDefinition, completionHandler: NIotSettingCallback?) {
        _player?.setDefinition(IVVideoDefinition(rawValue: definition.rawValue) ?? .high, completionHandler: { error in
            completionHandler?(error)
        })
    }
    
    /// 静音，  默认 false（即允许播放声音）
    open var mute: Bool = false {
        didSet {
            _player?.mute = mute
        }
    }
    
    /// 免提， 默认 true, 有外设时无效
    ///
    /// true 没有外设时外放声音,
    /// false  没有外设时听筒处播放声音
    open var handsFree: Bool = true {
        didSet {
            _player?.handsFree = handsFree
        }
    }
    
}

extension NIotPlayer {
    /// 视频画面
    open var videoView: UIView? { _player?.videoView }
    /// 当前设备观众人数
    open var audience: UInt { _player?.audience ?? 0 }
    /// 播放器状态
    open var status: NIotPlayerStatus? {
        guard let status = _player?.status else {
            return nil
        }
        return NIotPlayerStatus(rawValue: status.rawValue)
    }
    /// 当前播放时间戳（秒）
    open var pts: TimeInterval { _player?.pts ?? 0 }
    /// 是否正在录像
    open var isRecording: Bool { _player?.isRecording ?? false }
}

extension NIotPlayer {
    /// 预连接(可选)
    /// - note: 设备会发送流媒体信息头，但不会发送音视频数据
    @available(*, deprecated, message: "No longer supported, do nothing.")
    open func prepare() {
        
    }
    
    /// 开始播放
    /// - note: 设备会发送流媒体信息头，接着发送音视频数据
    open func play() {
        _player?.play()
    }
    
    /// 停止播放
    /// - note: 该操作APP将与设备断开连接
    open func stop() {
        _player?.stop()
    }
    
    /// 截图
    /// - Parameter completionHandler: 截图回调
    open func takeScreenshot(_ completionHandler: @escaping (UIImage?) -> Void) {
        _player?.takeScreenshot(completionHandler)
    }
    
    /// 开始录像
    /// - Parameters:
    ///   - savePath: 录像文件路径
    ///   - completionHandler: 完成回调
    open func startRecording(_ savePath: String, completionHandler: @escaping (_ savePath: String?, _ error: Error?) -> Void) {
        _player?.startRecording(savePath, completionHandler: completionHandler)
    }
    
    /// 停止录像
    open func stopRecording() {
        _player?.stopRecording()
    }
    
    /// 发送自定义数据
    /// 与设备建立连接后才可发送，适用于较大数据传输、实时性要求较高的场景，如多媒体数据传输。
    /// 接收到设备端发来的数据见`-[NIoTConnectionDelegate connection:didReceiveData:]`
    /// - Parameters:
    ///   - data: 要发送的数据，data.length不能超过 64000
    open func send(_ data: Data) {
        _player?.send(data)
    }
    
    /// 发送自定义数据
    /// - Parameters:
    ///   - data: 要发送的数据，data.length不能超过 64000
    ///   - sequence: 是否串行发送
    ///   - completionHandler: 完成回调。completionHandler非nil则通过callback回调；completionHandler为nil则通过代理回调；
    open func send(_ data: Data, sequence: Bool, completionHandler: ((_ data: Data?, _ error: Error?, _ finished: UnsafeMutablePointer<ObjCBool>) -> Void)?) {
        _player?.send(data, sequence: sequence) { data, error, finished in
            completionHandler?(data, error, finished)
        }
    }
    
}

extension NIotPlayer {
    
    /// 播放器调试模式，默认`NO`。若设为`YES`则在编/解码时将音视频数据写入Document根目录。说明文档: Docs/抓取音视频流方法.md
    /// @note ⚠️开启可能会导致卡顿。
    /// @code
    ///  播放相关音频文件:
    ///  au_rcv_in   音频 接收器 输入流
    ///  au_dec_in   音频 解码器 输入流
    ///  au_dec_out  音频 解码器 输出流
    ///
    ///  播放相关视频文件:
    ///  vi_rcv_in   视频 接收器 输入流
    ///  vi_dec_in   视频 解码器 输入流
    ///
    ///  对讲相关音频文件:
    ///  au_fill_in  音频 采集器 输出流
    ///  au_enc_in   音频 编码器 输入流
    ///  au_enc_out  音频 编码器 输出流
    ///
    ///  双向视频通话相关文件:
    ///  vi_enc_out  视频 编码器 输出流
    /// @endcode
    public static var debugMode: Bool = false {
        didSet {
            IVPlayer.debugMode = NIotPlayer.debugMode
        }
    }
}
