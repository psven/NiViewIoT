//
//  NIotNetworking.swift
//  NIot
//
//  Created by apple on 2021/11/15.
//

import UIKit
import IoTVideo

@objc
public enum NIotNetConfigLanguage: UInt {
   case Chinese = 1
   case English
}


@objcMembers
open class NIotNetworking: NSObject {
    
    public typealias CompletionHandler = (_ json: AnyObject?, _ error: Error?) -> Void
     
    @objc(sharedInstance)
    public static let shared = NIotNetworking()
      
    private let networkMgr = NVNetworkingManager.ShareInstance
    
    
    /// 初始化
    /// - Parameters:
    ///   - appName: app name
    ///   - appLanguage:  app language
    ///   - secretId: secret id
    ///   - secretKey:  secret key
    open func setup(appName: String, appLanguage: NIotNetConfigLanguage, secretId: String, secretKey: String) {
        // 因为 token 也在 NVEnvironment 里维护，所以这里把 appName、appLanguage、secretId、secretKey 也交由 NVEnvironment 维护
        NVEnvironment.shared.setup(appName: appName, appLanguage: appLanguage, secretId: secretId, secretKey: secretKey)
    }
    /// 语言发生变化时调用
    /// - Parameters:
    ///   - appLanguage:  app language
    open func update(appLanguage: NIotNetConfigLanguage) {
        NVEnvironment.shared.update(appLanguage: appLanguage)
    }
    
}

// MARK: - User
extension NIotNetworking {
    
    
    /// 发送邮箱验证码
    /// - Parameters:
    ///   - email: 邮箱
    ///   - completionHandler: 回调
    open func sendVerifyCodeFor(email: String, completionHandler: @escaping CompletionHandler) {
        networkMgr.getSecondDomain(for: email) { [weak self] in
            guard let self = self else { return }
            let api = NVApi.emailVerifyCode(email: email)
            self.networkMgr.request(api) { completionHandler($0.data, $0.error) }
        }
    }
    
    /// 发送手机验证码
    /// - Parameters:
    ///   - phone: 手机号码
    ///   - countryCode: 手机号码国家区号，目前仅支持中国，即：+86
    ///   - completionHandler: 回调
    open func sendVerifyCodeFor(phone: String, countryCode: String, completionHandler: @escaping CompletionHandler) {
        networkMgr.getSecondDomain(for: phone) { [weak self] in
            guard let self = self else { return }
            let api = NVApi.phoneVerifyCode(phone: phone, countryCode: countryCode)
            self.networkMgr.request(api) { completionHandler($0.data, $0.error) }
        }
    }
    
    /// 邮箱验证码登录
    /// - Parameters:
    ///   - email: 邮箱
    ///   - verifyCode: 邮箱验证码
    ///   - completionHandler: 回调
    open func login(email: String, verifyCode: String, completionHandler: @escaping CompletionHandler) {
        let api = NVApi.loginWithEmailVerifyCode(email: email, verifyCode: verifyCode)
        networkMgr.request(api) { response in
            if let dataDict = response.data as? [String : Any] {
                if let token = dataDict["token"] as? String {
                    NVEnvironment.shared.update(token: token)
                }
            }
            completionHandler(response.data, response.error)
        }
    }
    
    /// 邮箱密码登录
    /// - Parameters:
    ///   - email: 邮箱
    ///   - password: 密码
    ///   - completionHandler: 回调
    open func login(email: String, password: String, completionHandler: @escaping CompletionHandler) {
        networkMgr.getSecondDomain(for: email) { [weak self] in
            guard let self = self else { return }
            let api = NVApi.loginWithEmailPwd(email: email, password: password)
            self.networkMgr.request(api) { response in
                if let dataDict = response.data as? [String : Any] {
                    if let token = dataDict["token"] as? String {
                        NVEnvironment.shared.update(token: token)
                    }
                }
                completionHandler(response.data, response.error)
            }
        }
    }
    
    /// 手机验证码登录
    /// - Parameters:
    ///   - phone: 手机号码
    ///   - verifyCode: 手机验证码
    ///   - completionHandler: 回调
    open func login(phone: String, verifyCode: String, completionHandler: @escaping CompletionHandler) {
        let api = NVApi.loginWithPhoneVerifyCode(phone: phone, verifyCode: verifyCode)
        networkMgr.request(api) { response in
            if let dataDict = response.data as? [String : Any] {
                if let token = dataDict["token"] as? String {
                    NVEnvironment.shared.update(token: token)
                }
            }
            completionHandler(response.data, response.error)
        }
    }
    
    /// 手机密码登录
    /// - Parameters:
    ///   - phone: 手机号码
    ///   - password: 密码
    ///   - completionHandler: 回调
    open func login(phone: String, password: String, completionHandler: @escaping CompletionHandler) {
        networkMgr.getSecondDomain(for: phone) { [weak self] in
            guard let self = self else { return }
            let api = NVApi.loginWithPhonePwd(phone: phone, password: password)
            self.networkMgr.request(api) { response in
                if let dataDict = response.data as? [String : Any] {
                    if let token = dataDict["token"] as? String {
                        NVEnvironment.shared.update(token: token)
                    }
                }
                completionHandler(response.data, response.error)
            }
        }
    }
     
    
    /// token 免密登录
    /// - Parameters:
    ///   - token: token
    ///   - completionHandler: 回调
    open func login(token: String, completionHandler: @escaping CompletionHandler) {
        let api = NVApi.loginWithToken(token: token)
        networkMgr.request(api) { response in
            if let dataDict = response.data as? [String : Any] {
                if let token = dataDict["token"] as? String {
                    NVEnvironment.shared.update(token: token)
                } 
            }
            completionHandler(response.data, response.error)
            
        }
    }
    
    /// 退出登录
    /// - Parameters:
    ///   - uid: 用户 id
    ///   - completionHandler: 回调
    open func loginOut(uid: Int64, completionHandler: @escaping CompletionHandler) {
        let api = NVApi.logout(uid: uid)
        networkMgr.request(api) {
            completionHandler($0.data, $0.error)
            NVEnvironment.shared.update(token: "")
            NVEnvironment.shared.resetCurrentDomain()
        }
    }
    
    /// 更新用户密码
    /// - Parameters:
    ///   - account: 账号（email）
    ///   - uid: 用户 id
    ///   - password: 密码
    ///   - verifyCode: 验证码
    ///   - completionHandler: 回调
    open func updatePassword(account: String, uid: Int64, password: String, verifyCode: String, completionHandler: @escaping CompletionHandler) {
        let api = NVApi.updateLoginPwd(account: account, uid: uid, password: password, verifyCode: verifyCode)
        networkMgr.request(api) { completionHandler($0.data, $0.error) }
    }
    
    /// 注销账号
    /// - Parameters:
    ///   - account: 账号（email）
    ///   - uid: 用户 id
    ///   - verifyCode: 验证码
    ///   - completionHandler: 回调
    open func unregister(account: String, uid: Int64, verifyCode: String, completionHandler: @escaping CompletionHandler) {
        let api = NVApi.unregister(account: account, uid: uid, verifyCode: verifyCode)
        networkMgr.request(api) {
            completionHandler($0.data, $0.error)
            NVEnvironment.shared.update(token: "")
            NVEnvironment.shared.resetCurrentDomain()
            NVEnvironment.shared.update(domain: "", for: account)
        }
    }
    
    
    /// 更新用户头像
    /// - Parameters:
    ///   - uid: 用户 id
    ///   - image: 头像
    ///   - completionHandler: 回调
    open func udpateAvatar(uid: Int64, image: UIImage, completionHandler: @escaping CompletionHandler) {
        let api = NVApi.userImage(uid: uid, image: image)
        networkMgr.uploadImage(
            api: api,
            progressClosure: { (progress) in },
            successClosure: { (response) in completionHandler(response as AnyObject, nil) }
        )
    }
}

// MARK: - Device
extension NIotNetworking {
    
    /// 生成配网二维码
    /// - Parameters:
    ///   - uid: 用户 id
    ///   - timestamp: 时间戳，需要与 bindDevice 接口时间戳一致
    ///   - wifiName: wifi name
    ///   - wifiPassword: wifi password
    ///   - imgSize: image size
    /// - Returns: 二维码
    open func getQrCodeBitmap(uid: Int64, timestamp: Int64, wifiName: String, wifiPassword: String, imgSize: CGSize) -> UIImage? {
        var extraInfo = [String: String]()
        let strArr = NVEnvironment.shared.currentDomain.components(separatedBy: ".")
        if let region = strArr.first?.components(separatedBy: "-").last {
            extraInfo["B"] = region
        }
        extraInfo["6"] = String(uid)
        extraInfo["7"] = String(timestamp)
        extraInfo["9"] = getTimeZone()
        let language: IVNetConfigLanguage = {
            guard let appLanguage = NVEnvironment.shared.appLanguage,
                    let cfgLanguage = IVNetConfigLanguage.init(rawValue: appLanguage.rawValue) else {
                return .EN
            }
            return cfgLanguage
        }()
        return IVNetConfig.qrCode.createQRCode(withWifiName: wifiName, wifiPassword: wifiPassword, language: language, token: "", extraInfo: extraInfo, qrSize: imgSize)
    }
    
    /// 绑定设备
    /// - Parameters:
    ///   - uid: 用户 id
    ///   - timestamp: 时间戳，需要与 getQrCodeBitmap 接口时间戳一致
    ///   - completionHandler: 回调
    open func bindDevice(uid: Int64, timestamp: Int64, completionHandler: @escaping CompletionHandler) {
        
        let api = NVApi.bindDevice(uid: uid, timestamp: timestamp)
        networkMgr.request(api) { response in
            if let dataDict = response.data as? [String: Any] {
                NVLog("配网成功返回的设备数据--->\(dataDict)")
                if let devToken = dataDict["devToken"] as? String {
                    IVNetConfig.subscribeDevice(withAccessToken: devToken, deviceId: dataDict["tid"] as! String) { result, error in
                        NVLog("result: \(result)")
                    }
                }
            }
            completionHandler(response.data, response.error)
        }
    }
    
    /// 解绑设备
    /// - Parameters:
    ///   - uid: 用户 id
    ///   - accessId: accessId
    ///   - did: 设备 did
    ///   - tid: 设备 tid
    ///   - role: 0：主设备，1：分享的设备
    ///   - completionHandler: 回调
    open func unbindDevice(uid: Int64, accessId: Int64, did: Int64, tid: String, role: Int, completionHandler: @escaping CompletionHandler) {
        if role == 0 {
            IVMessageMgr.sharedInstance.sendData(toDevice: tid, data: "{\"data\":{\"deleteDevice\":\"\"}}".data(using: .utf8)!, withResponse: { (data, error) in
                
            })
        }
        let api = NVApi.unbindDevice(uid: uid, accessId: accessId, did: did, tid: tid, role: role)
        networkMgr.request(api) { completionHandler($0.data, $0.error) }
        
    }
    
    /// 获取设备列表
    /// - Parameters:
    ///   - uid: 用户 id
    ///   - completionHandler: 回调
    open func getDeviceList(uid: Int64, completionHandler: @escaping CompletionHandler) {
        let api = NVApi.deviceList(uid: uid)
        networkMgr.request(api) { completionHandler($0.data, $0.error) }
    }
    
    /// 更新设备名称
    /// - Parameters:
    ///   - did: 设备 did
    ///   - deviceName: 设备 name
    ///   - completionHandler: 回调
    open func updateDeviceName(did: Int64, deviceName: String, completionHandler: @escaping CompletionHandler) {
        let api = NVApi.updateDeviceName(did: did, deviceName: deviceName)
        networkMgr.request(api) { completionHandler($0.data, $0.error) }
    }
    
    /// 分享设备
    /// - Parameters:
    ///   - uid: 用户 id
    ///   - did: 设备 did
    ///   - accountToShare: account to share
    ///   - deviceName: device name
    ///   - completionHandler: 回调
    open func shareDevice(uid: Int64, did: Int64, accountToShare: String, deviceName: String, completionHandler: @escaping CompletionHandler) {
        let api = NVApi.shareDevice(uid: uid, accountToShare: accountToShare, did: did, deviceName: deviceName)
        networkMgr.request(api) { completionHandler($0.data, $0.error) }
    }
    
    /// 取消分享设备
    /// - Parameters:
    ///   - uid: 用户 id
    ///   - did: 设备 did
    ///   - accountToShare: account to share
    ///   - deviceName: device name
    ///   - completionHandler: 回调
    open func unshareDevice(uid: Int64, did: Int64, accountToShare: String, deviceName: String, completionHandler: @escaping CompletionHandler) {
        let api = NVApi.unshareDevice(uid: uid, accountToShare: accountToShare, did: did, deviceName: deviceName)
        networkMgr.request(api) { completionHandler($0.data, $0.error) }
    }
    
    /// 响应设备分享事件
    /// - Parameters:
    ///   - sid: 分享消息id
    ///   - hostUid: 分享用户id
    ///   - shareUid: 被分享用户id
    ///   - did: 设备 id
    ///   - choose: 1：接受 2：拒绝
    ///   - completionHandler: 回调
    open func responseDeviceSharing(sid: Int64, hostUid: Int64, shareUid: Int64, did: Int64, choose: Int, completionHandler: @escaping CompletionHandler) {
        let api = NVApi.responseDeviceSharing(sid: sid, hostUid: hostUid, shareUid: shareUid, did: did, choose: choose)
        networkMgr.request(api) { response in
            if choose == 1,
                let dataDict = response.data as? [String: Any],
                let devToken = dataDict["devToken"] as? String {
                NVLog("配网成功返回的设备数据--->\(dataDict)")
                IVNetConfig.subscribeDevice(withAccessToken: devToken, deviceId: dataDict["tid"] as! String) { result, error in
                    NVLog("result: \(result)")
                }
            }
            completionHandler(response.data, response.error)
        }
    }
    
    /// 获取分享消息列表
    /// - Parameters:
    ///   - uid: 用户 id
    ///   - completionHandler: 回调
    open func getShareMessage(uid: Int64, completionHandler: @escaping CompletionHandler) {
        let api = NVApi.getShareMessage(uid: uid)
        networkMgr.request(api) { completionHandler($0.data, $0.error) }
    }
    
    /// 获取最新分享消息
    /// - Parameters:
    ///   - uid: 用户 id
    ///   - completionHandler: 回调
    open func getLatestShareMessage(uid: Int64, completionHandler: @escaping CompletionHandler) {
        let api = NVApi.getLatestShareMessage(uid: uid)
        networkMgr.request(api) { completionHandler($0.data, $0.error) }
    }
    
    /// 设备分享用户列表
    /// - Parameters:
    ///   - uid: 用户 id
    ///   - did: 设备 id
    ///   - completionHandler: 回调
    open func getDeviceSharedUsersList(uid: Int64, did: Int64, completionHandler: @escaping CompletionHandler) {
        let api = NVApi.getDeviceSharedUsersList(uid: uid, did: did)
        networkMgr.request(api) { completionHandler($0.data, $0.error) }
    }
    
    
    /// 获取设备事件列表
    /// - Parameters:
    ///   - uid: 用户 id
    ///   - did: 设备 id
    ///   - messageType: 消息类型(104：按键唤醒，100：移动侦测，106：设备报警，105：低电报警，查看全部消息传 -1)
    ///   - startTime: 开始时间
    ///   - endTime: 结束时间
    ///   - page: 分页
    ///   - completionHandler: 回调
    open func getDeviceEventsList(uid: Int64, did: Int64, messageType: Int, startTime: Int64, endTime: Int64, page: Int, completionHandler: @escaping CompletionHandler) {
        let api = NVApi.getDeviceEventsList(uid: uid, did: did, messageType: messageType, startTime: startTime, endTime: endTime, page: page)
        networkMgr.request(api) { completionHandler($0.data, $0.error) }
    }
    
    /// 获取设备事件日历打点列表
    /// - Parameters:
    ///   - uid: 用户 id
    ///   - did: 设备 id
    ///   - messageType: 消息类型(104：按键唤醒，100：移动侦测，106：设备报警，105：低电报警，查看全部消息传 -1)
    ///   - completionHandler: 回调
    open func getDeviceEventsDatesList(uid: Int64, did: Int64, messageType: Int, completionHandler: @escaping CompletionHandler) {
        let api = NVApi.getDeviceEventsDatesList(uid: uid, did: did, messageType: messageType)
        networkMgr.request(api) { completionHandler($0.data, $0.error) }
    }
    
    /// 删除设备事件
    /// - Parameters:
    ///   - jsonArray: Json数组，字段包括（uid,did,createDate）
    ///   - completionHandler: 回调
    open func deleteDeviceEvents(jsonArray: [[String: AnyObject]], completionHandler: @escaping CompletionHandler) {
        // TODO: 支持云存后，需要同步调用腾讯云的接口
        let api = NVApi.deleteDeviceEvents(jsonArray: jsonArray)
        networkMgr.request(api) { completionHandler($0.data, $0.error) }
    }
    
}

// MARK: - Push
extension NIotNetworking {
    
    /// 上传手机推送token
    /// - Parameters:
    ///   - uid: 用户 id
    ///   - pushToken: 推送 token
    ///   - completionHandler: 回调
    open func putPushToken(uid: Int64, pushToken: String, completionHandler: @escaping CompletionHandler) {
        let api = NVApi.putPushToken(uid: uid, pushToken: pushToken)
        networkMgr.request(api) {
            NVEnvironment.shared.update(pushToken: pushToken)
            completionHandler($0.data, $0.error)
        }
    }
    
    /// 设置推送勿扰模式
    /// - Parameters:
    ///   - uid: 用户 id
    ///   - delayPattern: -1：不接收推送，0：接收推送，大于0：表示多少时间内不接收推送，单位为秒
    ///   - completionHandler: 回调
    open func setDisturbTime(uid: Int64, delayPattern: Int, completionHandler: @escaping CompletionHandler) {
        let api = NVApi.setDisturbTime(uid: uid, delayPattern: delayPattern)
        networkMgr.request(api) { completionHandler($0.data, $0.error) }
    }
    
    /// 获取当前设置的推送勿扰模式
    /// - Parameters:
    ///   - uid: 用户 id
    ///   - completionHandler: 回调
    open func getDisturbTime(uid: Int64, completionHandler: @escaping CompletionHandler) {
        let api = NVApi.getDisturbTime(uid: uid)
        networkMgr.request(api) { completionHandler($0.data, $0.error) }
    }
    
}

// MARK: - App
extension NIotNetworking {
    
    /// 检查app版本，获取是否有新版本
    /// - Parameters:
    ///   - currentVersion: 当前版本
    ///   - completionHandler: 回调
    open func checkAppVersion(currentVersion: String, completionHandler: @escaping CompletionHandler) {
        let api = NVApi.checkAppVersion(currentVersion: currentVersion)
        networkMgr.request(api) { completionHandler($0.data, $0.error) }
    }
    
}

