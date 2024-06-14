//
//  String+Extension.swift
//  AlamofireEncapsulation
//
//  Created by Ethan.Wang on 2018/9/7.
//  Copyright © 2018年 Ethan. All rights reserved.
//

import Foundation
import UIKit
import CommonCrypto

extension String {
    var length: Int {
        ///更改成其他的影响含有emoji协议的签名
        return self.utf16.count
    }
    
    /// 根据字节数获取长度
    var byteLength: Int {
        return self.utf8.count
    }
    
    /// 是否包含字符串
    func containsIgnoringCase(find: String) -> Bool {
        return self.range(of: find, options: .caseInsensitive) != nil
    }
    
    /// md5加密,添加这个方法后还要添加与oc的bridging文件
    func md5() -> String {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)

        CC_MD5(str!, strLen, result)
        let hash = NSMutableString()
        for num in 0 ..< digestLen {
            hash.appendFormat("%02x", result[num])
        }
        result.deinitialize(count: 1)

        return String(format: hash as String)
    }
    
    /// 截取任意位置到结束
    ///
    /// - Parameter end:
    /// - Returns: 截取后的字符串
    func stringCutToEnd(star: Int) -> String {
        if !(star < count) { return "截取超出范围" }
        let sRang = index(startIndex, offsetBy: star)..<endIndex
        return String(self[sRang])
    }
    
    //获取子字符串
    func subStringInRange(_ r: Range<Int>) -> String? {
        if r.lowerBound < 0 || r.upperBound > self.count {
            return nil
        }
        let startIndex = self.index(self.startIndex, offsetBy:r.lowerBound)
        let endIndex   = self.index(self.startIndex, offsetBy:r.upperBound)
        return String(self[startIndex..<endIndex])
    }
    
    // 截取字符串：从index到结束处
    // - Parameter index: 开始索引
    // - Returns: 子字符串
    func subStringFrom(_ index: Int) -> String {
        let theIndex = self.index(self.endIndex, offsetBy: index - self.count)
        return String(self[theIndex..<endIndex])
    }
    
    //从0索引处开始查找是否包含指定的字符串，返回Int类型的索引
    //返回第一次出现的指定子字符串在此字符串中的索引
    func findFirst(_ sub:String)->Int {
        var pos = -1
        if let range = range(of:sub, options: .literal ) {
            if !range.isEmpty {
                pos = self.distance(from:startIndex, to:range.lowerBound)
            }
        }
        return pos
    }
    
    //从0索引处开始查找是否包含指定的字符串，返回Int类型的索引
    //返回最后出现的指定子字符串在此字符串中的索引
    func findLast(_ sub:String)->Int {
        var pos = -1
        if let range = range(of:sub, options: .backwards ) {
            if !range.isEmpty {
                pos = self.distance(from:startIndex, to:range.lowerBound)
            }
        }
        return pos
    }
    
    //从指定索引处开始查找是否包含指定的字符串，返回Int类型的索引
    //返回第一次出现的指定子字符串在此字符串中的索引
    func findFirst(_ sub:String,_ begin:Int)->Int {
        let str:String = self.subStringFrom(begin)
        let pos:Int = str.findFirst(sub)
        return pos == -1 ? -1 : (pos + begin)
    }
    
    //从指定索引处开始查找是否包含指定的字符串，返回Int类型的索引
    //返回最后出现的指定子字符串在此字符串中的索引
    func findLast(_ sub:String,_ begin:Int)->Int {
        let str:String = self.subStringFrom(begin)
        let pos:Int = str.findLast(sub)
        return pos == -1 ? -1 : (pos + begin)
    }

    //获取字符串高度
    func heightForText(_ font: UIFont, width w: CGFloat) -> CGFloat {
        let size: CGSize = CGSize(width: w, height: CGFloat(MAXFLOAT))
        return sizeWithText(font: font, size: size).height
    }
    
    func widthForText(_ font: UIFont) -> CGFloat {
        return sizeWithText(font: font, size: CGSize(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT))).width
    }
    
    /// 获取字符串的宽高
    func sizeWithText(font: UIFont, size: CGSize) -> CGSize {
    let attributes = [NSAttributedString.Key.font: font]
    let option = NSStringDrawingOptions.usesLineFragmentOrigin
    let rect:CGRect = self.boundingRect(with: size, options: option, attributes: attributes, context: nil)
        return rect.size
    }
    
    // MARK: 字符串转字典
    func stringValueDic() -> [String : Any]?{
        let data = self.data(using: String.Encoding.utf8)
        if let dict = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String : Any] {
            return dict
        }
        return nil
    }
    
    //将原始的url编码为合法的url
    func urlEncoded() -> String {
        let encodeUrlString = self.addingPercentEncoding(withAllowedCharacters:
            .urlQueryAllowed)
        return encodeUrlString ?? ""
    }
     
    //将编码后的url转换回原始的url
    func urlDecoded() -> String {
        return self.removingPercentEncoding ?? ""
    }
    
    func base64Encoded() -> String {
        let temp = Data.init(base64Encoded: self)
        return String(data: temp!, encoding: .utf8)!
    }
    
    /// range转换为NSRange
    func nsRange(from range: Range<String.Index>) -> NSRange {
        return NSRange(range, in: self)
    }
    
    // MARK: 判断字符串是否全是空格
    var isBlank: Bool {
        let trimmedStr = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedStr.isEmpty
    }
    
    // MARK: 正则表达式
    var isMatchPhone: Bool {
        let regex = "^((13[0-9])|(14[57])|(15[0-35-9])|(16[6])|(17[0135-8])|(18[0-9])|(19[189]))\\d{8}$"
        let predicate = NSPredicate.init(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
    }
    
    var isMatchEmail: Bool {
        let regex = "^\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*$"
        let predicate = NSPredicate.init(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
    }
    
    ///MARK: string to date
    func stringToDate(formatStr: String = "yyyy.MM.dd") -> Date {
        let fmt = DateFormatter()
        fmt.timeZone = .init(abbreviation: "UTC")
        fmt.dateFormat = formatStr
        if let date = fmt.date(from: self) {
            return date
        }
        return Date()
    }
    
    ///MARK - ssid中文转码
    func ssidUrlEncode() -> String? {
        if length == 0 {
            return nil
        }
        var resStr = self
        for i in 0..<self.length {
            if let range = Range.init(NSMakeRange(i, 1)), let subStr = self.subStringInRange(range), !subStr.contains(" ") {
                if var formatStr = subStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), formatStr.length == 9 {
                    formatStr = formatStr.lowercased()
                    let result = formatStr.replacingOccurrences(of: "%", with: "\\\\x", options: .regularExpression, range: Range.init(NSMakeRange(0, formatStr.length), in: formatStr))
                    resStr = resStr.replacingOccurrences(of: subStr, with: result)
                }
            }
        }
        return resStr
    }
}
