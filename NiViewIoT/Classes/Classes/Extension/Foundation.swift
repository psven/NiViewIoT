//
//  Foundation.swift
//  IotVideoDemo
//
//  Created by JonorZhang on 2020/1/2.
//  Copyright © 2020 Tencentcs. All rights reserved.
//

import Foundation
import UIKit

extension Int {
    // MARK:- 转成 2位byte
    func nv_to2Bytes() -> [UInt8] {
        let UInt = UInt16.init(Double.init(self))
        return [UInt8(truncatingIfNeeded: UInt >> 8),UInt8(truncatingIfNeeded: UInt)]
    }
    // MARK:- 转成 4字节的bytes
    func nv_to4Bytes() -> [UInt8] {
        let UInt = UInt32.init(Double.init(self))
        return [UInt8(truncatingIfNeeded: UInt >> 24),
                UInt8(truncatingIfNeeded: UInt >> 16),
                UInt8(truncatingIfNeeded: UInt >> 8),
                UInt8(truncatingIfNeeded: UInt)]
    }
    // MARK:- 转成 8位 bytes
    func intToEightBytes() -> [UInt8] {
        let UInt = UInt64.init(Double.init(self))
        return [UInt8(truncatingIfNeeded: UInt >> 56),
            UInt8(truncatingIfNeeded: UInt >> 48),
            UInt8(truncatingIfNeeded: UInt >> 40),
            UInt8(truncatingIfNeeded: UInt >> 32),
            UInt8(truncatingIfNeeded: UInt >> 24),
            UInt8(truncatingIfNeeded: UInt >> 16),
            UInt8(truncatingIfNeeded: UInt >> 8),
            UInt8(truncatingIfNeeded: UInt)]
    }
}

extension Double {
    func toDateStr(withFormat fmt: String = "yyyyMMdd-HH:mm:ss.SSS") -> String {
        let interval:TimeInterval=TimeInterval.init(self)
        let date = Date(timeIntervalSince1970: interval)
        let dateformatter = DateFormatter()

        //自定义日期格式
        dateformatter.dateFormat = fmt
        return dateformatter.string(from: date as Date)
    }
    
    func toDate(withFormat fmt: String = "yyyyMMdd-HH:mm:ss.SSS") -> Date {
        let dateStr = self.toDateStr(withFormat: fmt)
        let date = dateStr.stringToDate(formatStr: fmt)
//        let timeZone = TimeZone.current
//        let seconds = timeZone.secondsFromGMT(for: date)
//        let newDate = date.addingTimeInterval(TimeInterval(seconds))
        return date
    }
    
    ///MARK: 0时区时间戳转换成当前时区的时间戳
//    func zeroTimeZoneToDateStr() -> TimeInterval {
//        var tmp = self
//        let zone = getTimeZone()
//        let GMTTime: TimeInterval = TimeInterval(TimeZone.current.secondsFromGMT())
//        if zone.containsIgnoringCase(find: "+") {
//            tmp += GMTTime
//        } else {
//            tmp -= GMTTime
//        }
//        return tmp
//    }
}

extension Data {
    func string(with encoding: String.Encoding) -> String? {
        return String(data: self, encoding: encoding)
    }
    
    func toDictionary() -> [String: Any]? {
        do {
            let json = try JSONSerialization.jsonObject(with: self, options: .mutableContainers)
            let dic = json as! Dictionary<String, Any>
            return dic
        } catch _ {
            return nil
        }
    }
}


@propertyWrapper
struct Trimmed { //自动清除空格和换行 包装器
    private var value: String = ""
    var wrappedValue: String {
        get { value }
        set { value = newValue.trimmingCharacters(in: .whitespacesAndNewlines) }
    }
    init(wrappedValue initialValue: String) {
        self.wrappedValue = initialValue
    }
}

extension Date {
    func string(withFormat fmt: String = "yyyyMMdd-HH:mm:ss.SSS") -> String {
        let fmtr = DateFormatter()
        fmtr.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone
        fmtr.locale = Locale.current
        fmtr.dateFormat = fmt
        return fmtr.string(from: self)
    }
    /// 获取当前 秒级 时间戳 - 10位
    var timeStamp : String {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        return "\(timeStamp)"
    }

    /// 获取当前 毫秒级 时间戳 - 13位
    var milliStamp : String {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let millisecond = CLongLong(round(timeInterval*1000))
        return "\(millisecond)"
    }
    
    ///MARK 获取零时区的时间戳(10位)
//    var zeroZoneStamp: String {
//        let zone = getTimeZone()
//        let GMTTime: TimeInterval = TimeInterval(TimeZone.current.secondsFromGMT())
//        var timeStamp = CLongLong(round(self.timeIntervalSince1970))
//        if zone.containsIgnoringCase(find: "+") {
//            timeStamp -= Int64(GMTTime)
//        } else {
//            timeStamp += Int64(GMTTime)
//        }
//        return "\(timeStamp)"
//    }
    
    ///MARK 获取零时区的时间戳(13位)
//    var zeroZoneMilliStamp: String {
//        let zone = getTimeZone()
//        let GMTTime: TimeInterval = TimeInterval(TimeZone.current.secondsFromGMT())*1000
//        var timeStamp = CLongLong(round(self.timeIntervalSince1970*1000))
//        if zone.containsIgnoringCase(find: "+") {
//            timeStamp -= Int64(GMTTime)
//        } else {
//            timeStamp += Int64(GMTTime)
//        }
//        return "\(timeStamp)"
//    }
    
    /// 有时间差的日期转换成当前时间并返回string
    static func localeDateToString(date localeDate: Date, formatter fmt: String = "yyyy.MM.dd") -> String {
        let timeZone = NSTimeZone.system
        let seconds = timeZone.secondsFromGMT(for: localeDate)
        let newDate = localeDate.addingTimeInterval(TimeInterval(seconds))
        let str: String = newDate.string(withFormat: fmt)
        return str
    }
    
    /// MARK - 获取当前日期零点的时间戳
    func getZeroOclockTimeStamp() -> TimeInterval {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        let ts = calendar.date(from: components)?.timeIntervalSince1970
        return ts!
    }
    
    /// MARK - 当前月份有多少天
    func numberOfDaysInMonth() -> Int {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: self)
        return range?.count ?? 0
    }
    
    /// MARK - 当前手机的日期
    func localDate() -> Date {
        let zone = TimeZone.current
        let interval = zone.secondsFromGMT()
        return self.addingTimeInterval(TimeInterval(interval))
    }
}

extension Array {
    // 防止数组越界
    subscript(safeIndex index: Int) -> Element? {
        set {
            if index < self.count,let newValue = newValue {
                self[index] = newValue
            }
        }
        get {
            if index < self.count {
                return self[index]
            } else {
                return nil
            }
        }
    }
    
    /// 数组转json
    func toJson() -> String? {
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions.fragmentsAllowed)
            let strJson = String(data: data, encoding: .utf8)
            return strJson
        } catch _ {
            return nil
        }
    }
}

extension Timer {
    //Timer弱引用
    class func nv_scheduledTimer(timeInterval: TimeInterval, repeats: Bool, completion: @escaping ((_ timer:Timer)->())) -> Timer{
        return Timer.scheduledTimer(timeInterval: timeInterval,
                                    target: self,
                                    selector: #selector(nv_completionLoop(timer:)),
                                    userInfo: completion,
                                    repeats: repeats)
    }
    
    @objc class func nv_completionLoop(timer:Timer) {
        guard let completion = timer.userInfo as? ((Timer) -> ()) else {
            return
        }
        completion(timer)
    }
}

extension Equatable where Self: Any {
    
    /// 是否等于给定序列的所有值
    ///
    ///     普通写法: if a == b && a == c && a == d { //true }
    ///     高级写法: if a.isEqual(allOf: b, c, d) { //true }
    /// - Parameter them: 要比较的参数序列
    /// - Returns: 是否等于
    public func isEqual(allOf them: Self...) -> Bool {
        for e in them {
            if e != self { return false }
        }
        return true
    }
    
    /// 是否等于给定序列的任意值
    ///
    ///     普通写法: if a == b || a == c || a == d { //true }
    ///     高级写法: if a.isEqual(oneOf: b, c, d) { //true }
    /// - Parameter them: 要比较的参数序列
    /// - Returns: 是否等于
    public func isEqual(oneOf them: Self...) -> Bool {
        for e in them {
            if e == self { return true }
        }
        return false
    }
}

extension UIImage {
    // 图片裁剪
    public func setImageFrame(_ rect: CGRect) -> UIImage? {
        guard let imageRef = self.cgImage else { return nil }
        guard let cgImage = imageRef.cropping(to: rect) else { return nil }
        let cutImage = UIImage.init(cgImage: cgImage)
        return cutImage
    }
}

