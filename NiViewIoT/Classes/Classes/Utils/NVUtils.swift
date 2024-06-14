//
//  NVUtils.swift
//  NiView
//
//  Created by nice on 2020/6/24.
//  Copyright © 2020 nice. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import IoTVideo

class NVUtilsManager: NSObject {
    static let share = NVUtilsManager()
    private override init() {}
    ///MARK: 保存所有的设备
//    public var devices: [NVDeviceModel] = []
    public var showMall: Bool = false
    public var IOTLinkStatus: IVLinkStatus {
        get { IoTVideo.sharedInstance.linkStatus }
    }
    public var addNewShareDevice: Bool = false
    public var singleAllowCellular = kCellularPlay //单次播放是否允许使用流量
    public var tempUserToken: String?  //用户token
    public var needRequestNewestShareMsg = true //是否需要请求最新的分享消息（点击推送栏进来不需要
}

// MARK: 系统相关
/// Info
public let kAppBundleInfoVersion = Bundle.main.infoDictionary ?? Dictionary()
/// plist:  AppStore 使用VersionCode 1.0.1
public let kAppBundleVersion = (kAppBundleInfoVersion["CFBundleShortVersionString" as String] as? String ) ?? ""
/// plist: 例如 1
public let kAppBundleBuild = (kAppBundleInfoVersion["CFBundleVersion"] as? String ) ?? ""
public let kAppDisplayName = (kAppBundleInfoVersion["CFBundleDisplayName"] as? String ) ?? ""
public let kAppBundleID = (kAppBundleInfoVersion["CFBundleIdentifier"] as? String) ?? ""
public let kAPPGroupKey = "group.com.niceviewer.nview"
public let kDeviceKey = "devicePlistDict"
public let kBrainTreeKey = "com.niceviewer.nview.payments"
public var kISDebug: Bool = false
   
//
//let kAppDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
//public let kWindow = kAppDelegate.window!
public var kShouldAutorotate: Bool = false

public var kFirstLaunch: Bool {
    get { UserDefaults.standard.bool(forKey: "firstLaunch") }
}
 
// MARK: ============================================================================
// MARK: Dictory Array Strig Object 闭包方式
///过滤null对象
public let kFilterNullOfObj:((Any)->Any?) = {(obj: Any) -> Any? in
    if obj is NSNull {
        return nil
    }
    return obj
}
 
///过滤null的字符串，当nil时返回一个初始化的空字符串
public let kFilterNullOfString:((Any)->String) = {(obj: Any) -> String in
    if obj is String {
        return obj as! String
    }
    return ""
}
 
/// 过滤null的数组，当nil时返回一个初始化的空数组
public let kFilterNullOfArray:((Any)->Array<Any>) = {(obj: Any) -> Array<Any> in
    if obj is Array<Any> {
        return obj as! Array<Any>
    }
    return Array()
}
 
/// 过滤null的字典，当为nil时返回一个初始化的字典
public let kFilterNullOfDictionary:((Any) -> Dictionary<AnyHashable, Any>) = {( obj: Any) -> Dictionary<AnyHashable, Any> in
    if obj is Dictionary<AnyHashable, Any> {
        return obj as! Dictionary<AnyHashable, Any>
    }
    return Dictionary()
}
 
// MARK: ============================================================================
// MARK: 设置Nib、Stryboard、UIImage
 
/// 根据imageName创建一个UIImage
public let imageNamed:((String) -> UIImage?) = { (imageName : String) -> UIImage? in
    return UIImage.init(named: imageName)
}
 
/// 根据Main.storyboard建立ViewController
public let VC_From_Main_SB:((String)-> UIViewController? ) = {(SBID : String) -> UIViewController? in
    return UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier:SBID)
}

///用户相关
public var kUserName: String! { get { UserDefaults.standard.string(forKey: "userName") ?? "" } }

public var kUserToken: String! { get { UserDefaults.standard.string(forKey: "userToken") ?? "" } }

///MARK: 用户信息
public var kAccountInfo: [String: Any]? { get { UserDefaults.standard.dictionary(forKey: "accountInfo") } }

///MARK: userid
public var kUserID: String! {
    get {
        guard let accountInfo = kAccountInfo else {
            return ""
        }
        if let int = accountInfo["id"] as? Int {
            return String(format: "%d", int)
        }
        return String(format: "%@", accountInfo["id"] as! CVarArg)
    }
}

public var kAccessID: String! {
    get {
        guard let accountInfo = kAccountInfo else {
            return ""
        }
        if let int = accountInfo["tAccessId"] as? Int64 {
            return String(format: "%ld", int)
        }
        return String(format: "%@", accountInfo["tAccessId"] as! CVarArg)
    }
}

///MARK: 配网Token
public var kDeviceConfigToken: String! { get { UserDefaults.standard.string(forKey: "deviceConfigToken") ?? "" } }

///MARK: 推送Token
public var kPushToken: String = UserDefaults.standard.string(forKey: "pushToken") ?? ""

///MARK: Bundle
public let kAPPBundleName: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String

///MARK: 是否允许流量播放
public var kCellularPlay: Bool { get { UserDefaults.standard.bool(forKey: "cellularPlay") } }
 
/// MARK: 指定范围内的随机数
public let randomCustom:(_ min: Int, _ max: Int) -> Int = { (min: Int, max: Int) -> Int in
    let y = arc4random() % UInt32(max) + UInt32(min)
    return Int(y)
}

///MARK: APP国际化
public let NVLang: ((String) -> String) = { (str: String) -> String in
    return NSLocalizedString(str, comment: "")
}

///MARK: 获取当前时区
public func getTimeZone() -> String {
    let time = TimeZone.current.secondsFromGMT()
    if labs(time) > 14*60*60 {
        return "GMT00:00"
    }
    return String(format: "GMT%@%02ld:%02ld", time<0 ? "-" : "+",labs(time/60/60),labs(time/60%60))
}

///MARK: 用户头像图片写入本地
public func writeImageToDocuments(imageUrl: String) {
    let urlStr = imageUrl.urlEncoded()
    if let url = NSURL(string: urlStr) {
        if let data = NSData(contentsOf: url as URL){
            let home = NSHomeDirectory() as NSString
            let docPath = home.appendingPathComponent("Documents") as NSString
            let filePath = docPath.appendingPathComponent("profilePhoto.jpg")
            data.write(toFile: filePath, atomically: true)
        }
    }
}

///MARK: 从本地读取用户头像
public func readWithFile() -> UIImage? {
    let home = NSHomeDirectory() as NSString
    let docPath = home.appendingPathComponent("Documents") as NSString
    /// 获取文本文件路径
    let filePath = docPath.appendingPathComponent("profilePhoto.jpg")
    let image = UIImage.init(contentsOfFile: filePath)
    if image == nil {
        return nil
    }else{
        return image!
    }
}

///MARK: 本地删除用户头像
public func removeFile() {
    let manager = FileManager.default
    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
    let uniquePath = path.appendingPathComponent("profilePhoto.jpg")
    if manager.fileExists(atPath: uniquePath) {
      do {
          try FileManager.default.removeItem(atPath: uniquePath)
      } catch {
          NVLog("error:\(error)")
      }
    }
}

///MARK: 获取手机的UUID
private var UUID: String?
func getUUID() -> String {
    var devUUID = NVKeychain.readData(kAppBundleBuild)
    guard devUUID is String else {
        devUUID = UIDevice.current.identifierForVendor!.uuidString
        UUID = (devUUID as! String).replacingOccurrences(of: "-", with: "")
        if NVKeychain.saveData(UUID!, with: kAppBundleBuild) {
            return UUID!
        } else {
            return UUID!
        }
    }
    UUID = (devUUID as! String)
    guard UUID!.length > 0 else {
        devUUID = UIDevice.current.identifierForVendor!.uuidString
        if NVKeychain.saveData(devUUID, with: kAppBundleBuild) {
            return devUUID as! String
        } else {
            return UUID!
        }
    }
    return UUID!
}

///MARK 系统权限
public func judgeCameraJurisdiction(viewController: UIViewController) -> Bool {
    let status = AVCaptureDevice.authorizationStatus(for: .video)
    if status == .denied {
        let alertController = UIAlertController.init(title: NVLang("account_photo_jurisdiction"), message: nil, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction.init(title: NVLang("common_confirm"), style: .default, handler: { (action) in
            
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
            
        }))
        
        alertController.addAction(UIAlertAction.init(title: NVLang("common_cancel"), style: .cancel, handler: nil))
        viewController.present(alertController, animated: true, completion: nil)
        return false
    }
    return true
}

//保存到相册
//public func creationRequestForAsset(_ asset: Any, target: UIViewController?, showHud: Bool = true) {
//    PHPhotoLibrary.shared().performChanges({
//        if let image = asset as? UIImage {
//            PHAssetChangeRequest.creationRequestForAsset(from: image)
//        } else if let url = asset as? URL {
//            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
//        }
//    }) { (_, error) in
//        guard showHud else { return }
//        DispatchQueue.main.async {
//            let msg = (error != nil) ? NVLang("common_operating_fail") : (asset is UIImage ? NVLang("device_snap_success") : NVLang("device_recording_success"))
//            if let target = target {
//                NVHud.showMessage(msg, toView: target.view)
//            } else {
//                NVHud.showMessage(msg, toView: kWindow)
//            }
//        }
//    }
//}

///MARK: 网络请求
public func postAPNSToken(isLogout: Bool = false) {
    if kAccountInfo != nil, kPushToken.length > 0 {
        let token = isLogout ? "" : kPushToken
        let urlStr = String(format: NV_User_PushToken, arguments: [kUserID.aesEncode(), isLogout ? "" : "{\"ios\":\"\(token)\"}".aesEncode()])
        
//        NVNetworkingManager.ShareInstance.putData(url: urlStr, params: nil, success: { (response) in
//            NVLog("推送token上传成功!!!")
//        }) { (error) in
//            
//        }
    }
}

///MARK: 切换分辨率操作
/*
public func changeResolution(deviceID: String, newValue: Int) {
    guard deviceID.length > 0 else {
        return
    }
    
    if var resolutionDataArr = UserDefaults.standard.value(forKey: "resolutionDataArr") as? [[String: String]] {
        var tempDict: [String: String] = [:]
        for resolutionDict in resolutionDataArr {
            if deviceID == resolutionDict["did"] {
                tempDict = resolutionDict
                tempDict["resolution"] = "\(newValue)"
                let index = resolutionDataArr.firstIndex(of: resolutionDict)
                resolutionDataArr[index!] = tempDict
                break
            }
        }
        if tempDict.keys.count == 0 {
            tempDict["did"] = deviceID
            tempDict["resolution"] = "\(newValue)"
            resolutionDataArr.append(tempDict)
        }
        UserDefaults.standard.setValue(resolutionDataArr, forKey: "resolutionDataArr")
        UserDefaults.standard.synchronize()
    } else {
        var resolutionDataArr = [[String: String]]()
        let resolutionDict = ["did": deviceID, "resolution": "\(newValue)"]
        resolutionDataArr.append(resolutionDict)
        UserDefaults.standard.setValue(resolutionDataArr, forKey: "resolutionDataArr")
        UserDefaults.standard.synchronize()
    }
}

func getResolution(deviceModel: NVDeviceModel) -> IVVideoDefinition? {
    guard deviceModel.device.id.length > 0 else {
        return nil
    }
    if let resolutionDataArr = UserDefaults.standard.value(forKey: "resolutionDataArr") as? [[String: String]] {
        for resolutionDict in resolutionDataArr {
            if deviceModel.device.id == resolutionDict["did"] {
                return resolutionDict["resolution"] == "0" ? .mid : .high
            }
        }
    }
    
    return NVDevicePlayViewModel.is4gDevice(deviceModel) ? .mid : .high
}
 */

/// MARK:初始化IOTsdk和获取设备配网的token
public func setupIOTSDKAndDeviceConfigToken() {
    if let accountInfo = kAccountInfo {
        IoTVideo.sharedInstance.register(withAccessId: "\(accountInfo["tAccessId"] as! Int64)", accessToken: accountInfo["tAccessToken"] as! String)
//        IVNetConfig.getToken { (token, error) in
//            if error == nil, token != nil {
//                UserDefaults.standard.set(token, forKey: "deviceConfigToken")
//            }
//        }
    }
}

//判断系统选择的语言
func getCurrentLanguage() -> String {
    let preferredLang = Bundle.main.preferredLocalizations.first! as NSString
    switch String(describing: preferredLang) {
    case "en-US", "en-CN":
     return "en"//英文
    case "zh-Hans-US","zh-Hans-CN","zh-Hant-CN","zh-TW","zh-HK","zh-Hans":
     return "zh"//中文
    default:
     return "en"
    }
}

///MARK - 跳转到App store
func gotoAPPStore() {
    let url = NSURL.init(string: "itms-apps://apps.apple.com/cn/app/niview/id1518203527")
    if UIApplication.shared.canOpenURL(url! as URL) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url! as URL)
        }
    }
}

extension Dictionary {
    public func toString() -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: self) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
}

// MARK: 字典转字符串
public func dicValueString(_ dic:[String : Any]) -> String? {
    let data = try? JSONSerialization.data(withJSONObject: dic, options: [])
    let str = String(data: data!, encoding: .utf8)
    return str
}

public func stringValueArray(jsonString:String) -> NSArray? {
    if let jsonData:Data = jsonString.data(using: .utf8), let array = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? NSArray {
        return array
    } else {
        return nil
    }
}
