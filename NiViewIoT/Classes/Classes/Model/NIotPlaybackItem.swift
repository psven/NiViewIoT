//
//  NIotPlaybackPage.swift
//  NIot
//
//  Created by apple on 2021/11/18.
//

import UIKit
import IoTVideo

/// 回放文件
@objcMembers
public class NIotPlaybackItem: NSObject {
    /// 回放文件起始时间（秒），用UTC+0表示
    public let startTime: TimeInterval
    /// 回放文件结束时间（秒），用UTC+0表示
    public let endTime: TimeInterval
    /// 回放文件持续时间（秒），duration = endTime - startTime
    public let duration: TimeInterval
    /// 回放文件类型（例如手动录像、人形侦测等，由设备端应用层定义）
    public let type: String
    
    public init(startTime: TimeInterval, endTime: TimeInterval, duration: TimeInterval, type: String) {
        self.startTime = startTime
        self.endTime = endTime
        self.duration = duration
        self.type = type
    }
    init(ivPBItem: IVPlaybackItem) {
        self.startTime = ivPBItem.startTime
        self.endTime = ivPBItem.endTime
        self.duration = ivPBItem.duration
        self.type = ivPBItem.type
    }
}

extension IVPlaybackItem {
    convenience init(niPBItem: NIotPlaybackItem) {
        self.init()
        self.startTime = niPBItem.startTime
        self.endTime = niPBItem.endTime
        self.duration = niPBItem.duration
        self.type = niPBItem.type
    }
}

/// 回放文件分页
@objcMembers
public class NIotPlaybackPage: NSObject {
    /// 当前页码索引
    public let pageIndex: UInt32
    /// 总页数
    public let totalPage: UInt32
    /// 回放文件数组
    public let items: [AnyObject]
    
    public init(pageIndex: UInt32, totalPage: UInt32, items: [AnyObject]) {
        self.pageIndex = pageIndex
        self.totalPage = totalPage
        self.items = items
    }
}
