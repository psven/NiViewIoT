//
//  NVLog.swift
//  NiView
//
//  Created by nice on 2020/8/6.
//  Copyright © 2020 nice. All rights reserved.
//

import UIKit

func NVLog<T>(_ message: T,
              file: String = #file,
              method: String = #function,
              line: Int = #line) {
    guard kISDebug else { return }
    let format = DateFormatter()
    format.dateFormat = "HH:mm:ss.SSS"
    let dateStr = format.string(from: Date())
    let logStr = "[\(dateStr)]:\((file as NSString).lastPathComponent)[\(line)], \(method): \(message)"
    //log写文件
    print(logStr)
    let dest = LogDestination()
    dest.write(logStr)
}

func NVNetworkLog<T>(_ message: T) {
    guard kISDebug else { return }
    let format = DateFormatter()
    format.dateFormat = "HH:mm:ss.SSS"
    let dateStr = format.string(from: Date())
    let logStr = "[\(dateStr)]:\(message)"
    //log写文件
    print(logStr)
    let dest = LogDestination()
    dest.write(logStr)
}

final class LogDestination: TextOutputStream {
    private let path: String
    init() {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        path = paths.first! + "/log"
    }

    func write(_ string: String) {
        if let data = string.data(using: .utf8),
            let fileHandle = FileHandle(forWritingAtPath: path) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(data)
        }
    }
}

