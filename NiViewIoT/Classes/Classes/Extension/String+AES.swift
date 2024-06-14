//
//  String+AES.swift
//  NiView
//
//  Created by nice on 2021/1/27.
//  Copyright © 2021 nice. All rights reserved.
//

import Foundation
import UIKit
import CryptoSwift
 
extension String {
    
    private var nv_key: String { "d5%kBl^Rg3C%sfZl" }
    
    ///MARK AES加密
    func aesEncode() -> String {
        // 从String 转成data
        let data = self.data(using: String.Encoding.utf8)
        
        // byte 数组
        var encrypted: [UInt8] = []
        do {
            let aes = try AES(key: Array(nv_key.utf8), blockMode: ECB(), padding: .pkcs5)
            encrypted = try aes.encrypt(data!.bytes)
        } catch {
            
        }
        
        let encoded = Data(encrypted)
        //加密结果要用Base64转码
//        let base64Str = encoded.base64EncodedString()
        let tagStr: String = encoded.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0))
        let set: CharacterSet = CharacterSet.init(charactersIn: "+=\"#%/<>?@\\^`{|}").inverted
        let encodeString: String = tagStr.addingPercentEncoding(withAllowedCharacters: set)!
        return encodeString
    }
    
    ///  MARK:  AES-ECB128解密
    func aesDecode() -> String {
        //url解码
        let urlDecodeStr = self.removingPercentEncoding!
        //decode base64
        let data = NSData(base64Encoded: urlDecodeStr, options: NSData.Base64DecodingOptions.init(rawValue: 0))
        
        // byte 数组
        var encrypted: [UInt8] = []
        guard let count = data?.length else {
            return ""
        }
        
        // 把data 转成byte数组
        for i in 0..<count {
            var temp:UInt8 = 0
            data?.getBytes(&temp, range: NSRange(location: i,length:1 ))
            encrypted.append(temp)
        }
        
        // decode AES
        var decrypted: [UInt8] = []
        do {
            decrypted = try AES(key: Array(nv_key.utf8), blockMode: ECB(), padding: .pkcs5).decrypt(encrypted)
        } catch {
            return ""
        }
        
        // byte 转换成NSData
        let encoded = Data(decrypted)
        var str = ""
        //解密结果从data转成string
        str = String(bytes: encoded.bytes, encoding: .utf8) ?? ""
        return str
    }
}
