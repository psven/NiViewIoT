//
//  NVAPI.swift
//  NiView
//
//  Created by nice on 2020/7/20.
//  Copyright © 2020 nice. All rights reserved.
//

import UIKit
import Alamofire

enum Domain: String {
    case release
    
    var host: String {
        switch self {
        case .release:
//            return "https://cloud-nc.niceviewer.com:8463"
            return "https://\(NVEnvironment.shared.currentDomain):8463"
        }
    }
}

enum NVApi {
    /// 二级域名
    case userRegion(account: String)
    /// 邮箱验证码登录
    case loginWithEmailVerifyCode(email: String, verifyCode: String)
    /// 邮箱密码登录
    case loginWithEmailPwd(email: String, password: String)
    /// 手机验证码登录
    case loginWithPhoneVerifyCode(phone: String, verifyCode: String)
    /// 手机密码登录
    case loginWithPhonePwd(phone: String, password: String)
    /// token 免密登录
    case loginWithToken(token: String)
    /// 退出登录
    case logout(uid: Int64)
    /// 发送邮箱验证码
    case emailVerifyCode(email: String)
    /// 发送手机验证码
    case phoneVerifyCode(phone: String, countryCode: String)
    /// 更新用户密码
    case updateLoginPwd(account: String, uid: Int64, password: String, verifyCode: String)
    /// 注销
    case unregister(account: String, uid: Int64, verifyCode: String)
    /// 更新用户头像
    case userImage(uid: Int64, image: UIImage)
    /// 获取设备列表
    case deviceList(uid: Int64)
    /// 绑定设备
    case bindDevice(uid: Int64, timestamp: Int64)
    /// 解绑设备
    case unbindDevice(uid: Int64, accessId: Int64, did: Int64, tid: String, role: Int)
    /// 更新设备名称
    case updateDeviceName(did: Int64, deviceName: String)
    /// 分享设备
    case shareDevice(uid: Int64, accountToShare: String, did: Int64, deviceName: String)
    /// 取消分享设备
    case unshareDevice(uid: Int64, accountToShare: String, did: Int64, deviceName: String)
    
    /// 响应设备分享事件
    case responseDeviceSharing(sid: Int64, hostUid: Int64, shareUid: Int64, did: Int64, choose: Int)
    /// 获取分享消息列表
    case getShareMessage(uid: Int64)
    /// 获取最新分享消息
    case getLatestShareMessage(uid: Int64)
    /// 设备分享用户列表
    case getDeviceSharedUsersList(uid: Int64, did: Int64)
    
    /// 获取设备事件列表
    case getDeviceEventsList(uid: Int64, did: Int64, messageType: Int, startTime: Int64, endTime: Int64, page: Int)
    /// 获取设备事件日历打点列表
    case getDeviceEventsDatesList(uid: Int64, did: Int64, messageType: Int)
    /// 删除设备事件
    case deleteDeviceEvents(jsonArray: [[String: AnyObject]])
    
    /// 上传手机推送token
    case putPushToken(uid: Int64, pushToken: String)
    /// 设置推送勿扰模式
    case setDisturbTime(uid: Int64, delayPattern: Int)
    /// 获取当前设置的推送勿扰模式
    case getDisturbTime(uid: Int64)
    
    /// 检查app版本，获取是否有新版本
    case checkAppVersion(currentVersion: String)
}

extension NVApi {
    
    var parameters: [String: Any]? {
        return _encodedParameters
    }
    
    private var _parameters: [String: Any]? {
        switch self {
        case .userRegion(let account):
            return ["account": account]
        case .loginWithEmailVerifyCode(let email, let verifyCode):
            return ["email": email, "verify": verifyCode]
        case .loginWithEmailPwd(let email, let password):
            return ["email": email, "pass": password]
        case .loginWithPhoneVerifyCode(let phone, let verifyCode):
            return ["phone": phone, "verify": verifyCode]
        case .loginWithPhonePwd(let phone, let password):
            return ["phone": phone, "pass": password]
        case .logout(let uid):
            return ["id": uid, "token": "{\"ios\":\"\(NVEnvironment.shared.pushToken)\"}"]
        case .emailVerifyCode(let email):
            return ["email": email]
        case .phoneVerifyCode(let phone, let countryCode):
            return ["phone": phone, "country": countryCode]
            
            
            
        case .bindDevice(let uid, let timestamp):
            return ["uid": uid, "time": timestamp]
        case .shareDevice(let uid, let accountToShare, let did, let deviceName):
            return ["uid": uid, "account": accountToShare, "did": did, "devName": deviceName]
        case .unshareDevice(let uid, let accountToShare, let did, let deviceName):
            return ["uid": uid, "account": accountToShare, "did": did, "devName": deviceName]
        case .deviceList(let uid):
            return ["uid": uid]
            
        case .getShareMessage(let uid):
            return ["uid": uid]
        case .getLatestShareMessage(let uid):
            return ["uid": uid]
        case .getDeviceSharedUsersList(let uid, let did):
            return ["uid": uid, "did": did]
            
        case .getDeviceEventsList(let uid, let did, let messageType, let startTime, let endTime, let page):
            return ["uid": uid, "did": did, "messageType": messageType, "startTime": startTime, "endTime": endTime, "page": page]
        case .getDeviceEventsDatesList(let uid, let did, let messageType):
            return ["uid": uid, "did": did, "messageType": messageType]
        case .deleteDeviceEvents(let jsonArray):
            return ["deleteStr": jsonArray.toJson() ?? ""]
            
        case .setDisturbTime(let uid, let delayPattern):
            return ["uid": uid, "delayPattern": delayPattern]
        case .getDisturbTime(let uid):
            return ["uid": uid]
            
            
        case .checkAppVersion(let currentVersion):
            return ["cur_version": currentVersion, "mob_platform": "ios"]
            
        case .loginWithToken: // token登录的token 放在 header 里
            return nil
        case .userImage, .unregister, .unbindDevice, .updateLoginPwd, .updateDeviceName, .responseDeviceSharing, .putPushToken:
            return nil
            
        }
    }
    
    private var _encodedParameters: [String: Any]? {
        guard let parameters = _parameters else {
            return nil
        }
        NVNetworkLog("🟡Parameters(Plain Text):\(parameters)")
        
        var encParams = parameters
        if method == "POST" {
            encParams = encodeParametersForPOST(parameters)
        } else if method == "GET" {
            encParams = encodeParametersForGET(parameters)
        }
        return encParams
    }
    
    private func encodeParametersForGET(_ parameters:[String: Any]) -> [String: Any] {
        // GET 请求，只加密 params.value
        var encParams = [String: Any]()
        for key in parameters.keys {
            let value = parameters[key]
            if value is [String: Any]
                || value is [Any]
                || value is Set<AnyHashable> {
                encParams[key] = value
            } else {
                if key == "role" {
                    encParams[key] = value
                } else {
                    if let valueStr = value as? String {
                        encParams[key] = valueStr.aesEncode()
                    } else if let valueData = value as? Data, let valueStr = String.init(data: valueData, encoding: .utf8) {
                        encParams[key] = valueStr.aesEncode()
                    } else if let value = value {
                        encParams[key] = "\(value)".aesEncode()
                    }
                }
            }
        }
        return encParams
    }
    
    private func encodeParametersForPOST(_ parameters:[String: Any]) -> [String: Any] {
        // 每个 value 都要转成 String 类型
        var tempParams = [String: String]()
        for key in parameters.keys {
            let value = parameters[key]
            if value is [String: Any]
                || value is [Any]
                || value is Set<AnyHashable> {
                // TODO: POST 请求参数中如果有非基本数据类型该如何处理？
                print("🔴 POST 请求参数中有非基本数据类型，目前未处理")
//                tempParams[key] = value
            } else {
                if let valueStr = value as? String {
                    tempParams[key] = valueStr
                } else if let valueData = value as? Data, let valueStr = String.init(data: valueData, encoding: .utf8) {
                    tempParams[key] = valueStr
                } else if let value = value {
                    tempParams[key] = "\(value)"
                }
            }
        }
        // POST 请求，加密整个 params
        return ["data": tempParams.toString()?.aesEncode() ?? ""]
    }
}

extension NVApi {
    static var baseUrl: String { Domain.release.host }
    
    /// 请求完整地址
    var url: String {
        return "\(NVApi.baseUrl)\(version)\(serviceName)\(path)"
    }
    
    var version: String {
        switch self {
        default: return "/v1"
        }
    }
    
    var serviceName: String {
        switch self {
        case .userRegion, .loginWithEmailVerifyCode, .loginWithEmailPwd, .loginWithPhoneVerifyCode, .loginWithPhonePwd, .loginWithToken, .logout, .updateLoginPwd, .userImage, .unregister, .putPushToken, .setDisturbTime, .getDisturbTime:
            return "/user"
        case .emailVerifyCode, .phoneVerifyCode:
            return "/cloudService"
        case .bindDevice, .unbindDevice, .updateDeviceName, .shareDevice, .unshareDevice, .deviceList, .getDeviceSharedUsersList:
            return "/device"
        case .responseDeviceSharing, .getShareMessage, .getLatestShareMessage:
            return "/shareMess"
        case .getDeviceEventsList, .getDeviceEventsDatesList, .deleteDeviceEvents:
            return "/devMess"
        case .checkAppVersion:
            return "/appVersion"
        }
    }
    
    var path: String {
        switch self {
        case .userRegion: return "/userRegion"
        case .loginWithEmailVerifyCode, .loginWithEmailPwd: return "/user_e"
        case .loginWithPhoneVerifyCode, .loginWithPhonePwd: return "/user"
        case .loginWithToken: return "/user_t"
        case .logout: return "/user_out"
        case .emailVerifyCode: return "/sms_e"
        case .phoneVerifyCode: return "/sms_p"
        case .userImage: return "/user_img"
            
        case .bindDevice: return "/bind_d"
        case .shareDevice: return "/device_s"
        case .unshareDevice: return "/device_us"
        case .deviceList: return "/devices"
            
        case .getShareMessage: return "/shareMess"
        case .getLatestShareMessage: return "/shareMess_li"
        case .getDeviceSharedUsersList: return "/shares"
            
        case .getDeviceEventsList, .deleteDeviceEvents: return "/devMess"
        case .getDeviceEventsDatesList: return "/devMessDates"
             
            
        case .setDisturbTime: return "/setDisturbTime"
        case .getDisturbTime: return "/getDisturbTime"
            
        case .checkAppVersion: return "/appVersion"
            
        case .updateLoginPwd(let account, let uid, let password, let verifyCode):
            let cAccount = account.aesEncode()
            let cUid = String(uid).aesEncode()
            let cPwd = password.aesEncode()
            let cVerifyCode = verifyCode.aesEncode()
            return "/user?account=\(cAccount)&id=\(cUid)&verify=\(cVerifyCode)&pass=\(cPwd)"
            
        case .unregister(let account, let uid, let verifyCode):
            let cAccount = account.aesEncode()
            let cUid = String(uid).aesEncode()
            let cVerifyCode = verifyCode.aesEncode()
            return "/unregister?account=\(cAccount)&uid=\(cUid)&verify=\(cVerifyCode)"
            
        case .unbindDevice(let uid, let accessId, let did, let tid, let role):
            let cUid = String(uid).aesEncode()
            let cAccessId = String(accessId).aesEncode()
            let cDid = String(did).aesEncode()
            let cTid = tid.aesEncode()
            let cRole = String(role).aesEncode()
            return "/device?did=\(cDid)&role=\(cRole)&uid=\(cUid)&accessId=\(cAccessId)&tid=\(cTid)"
            
        case .updateDeviceName(let did, let deviceName):
            let cDid = String(did).aesEncode()
            let cDeviceName = deviceName.aesEncode()
            return "/device?did=\(cDid)&devName=\(cDeviceName)"
            
        case .responseDeviceSharing(let sid, let hostUid, let shareUid, let did, let choose):
            let cSid = String(sid).aesEncode()
            let cHostUid = String(hostUid).aesEncode()
            let cShareUid = String(shareUid).aesEncode()
            let cDid = String(did).aesEncode()
            let cChoose = String(choose).aesEncode()
            return "/shareMess?did=\(cDid)&host_uid=\(cHostUid)&sid=\(cSid)&share_uid=\(cShareUid)&choose=\(cChoose)"
            
        case .putPushToken(let uid, let pushToken):
            let cUid = String(uid).aesEncode()
            let cPushToken = "{\"ios\":\"\(pushToken)\"}".aesEncode()
            return "/pushToken?id=\(cUid)&token=\(cPushToken)"
        }
    }
    
    var method: String {
        switch self {
        case .userRegion, .loginWithEmailPwd, .loginWithPhonePwd, .loginWithToken, .deviceList, .logout, .getShareMessage, .getLatestShareMessage, .getDeviceSharedUsersList, .getDeviceEventsList, .getDeviceEventsDatesList, .setDisturbTime, .getDisturbTime, .checkAppVersion:
            return "GET"
        case .emailVerifyCode, .phoneVerifyCode, .loginWithEmailVerifyCode, .loginWithPhoneVerifyCode, .bindDevice, .shareDevice, .unshareDevice, .deleteDeviceEvents:
            return "POST"
        case .updateLoginPwd, .updateDeviceName, .responseDeviceSharing, .putPushToken:
            return "PUT"
        case .unregister, .unbindDevice:
            return "DELETE"
        case .userImage: // 上传头像走上传接口，不需要 method 参数
            return "POST"
        }
    }
    /// 编码方式
    var encoding: ParameterEncoding {
        switch method {
        case "POST", "PUT", "DELETE":
            return JSONEncoding.default
        default:
            return URLEncoding(arrayEncoding: .noBrackets)
        }
    }
    /// 请求头
    var headers: [String: String] {
        guard var appName = NVEnvironment.shared.appName?.lowercased(),
              let appLanguage = NVEnvironment.shared.appLanguage,
              let secretId = NVEnvironment.shared.secretId,
              let secretKey = NVEnvironment.shared.secretKey else {
            print("NIot SDK environment missing required values: appName/appLanguage/secretId/secretKey, please setup these values with 'NIotNetworking.setup(appName:appLanguage:)'")
            return [:]
        }
        let timestamp = "\(Date().milliStamp)".aesEncode()
        
        // 如果传递的请求头appName等于niview，直接返回失败，或者替换成空字符串，由接口返回失败
        if appName == "niview" {
            appName = ""
        }
        let appLanguagueStr = appLanguage == .Chinese ? "zh" : "en"
        
        var headers = ["Content-type": "application/json;charset=utf-8",
                       "timestamp": timestamp,
                       "Accept": "application/json",
                       "app-name": appName,
                       "app-lang": appLanguagueStr,
                       "secret-id": secretId.aesEncode(),
                       "secret-key": secretKey.aesEncode()]

        if let token = NVEnvironment.shared.token, !token.isEmpty {
            headers["token"] = token.aesEncode()
        }
        if case .loginWithToken(let token) = self {
            headers["token"] = token.aesEncode()
        }
        return headers
    }
    
    
}

//一级
var hostDomain = "cloud-nc.niceviewer.com" //根域名

//var baseDomain = "https://172.16.1.56:8463/v1/"
var baseDomain: String { get { String(format: "https://%@:8463/v1/", hostDomain) } }
//#if DEBUG
//var baseDomain: String { get { "https://test-en.niceviewer.com:8463/v1/" } }
//#else
//var baseDomain: String { get { String(format: "https://%@:8463/v1/", hostDomain) } }
//#endif

var baseUserDomain: String { get { baseDomain + "user/" } }
var baseEventDomain: String { get { baseDomain + "devMess/" } }
var baseDeviceDomain: String { get { baseDomain + "device/" } }
var baseServiceDomain: String { get { baseDomain + "cloudService/" } }
var baseCloudDomain: String { get { baseDomain + "cloudOrder/" } }
var baseShareMessageDomain: String { get { baseDomain + "shareMess/" } }
var basePayDomain: String { get { baseDomain + "pay/" } }
var baseCellularDomain: String { get { baseDomain + "sim/" } }

/** 登录注册 */
var NV_User_Region: String { get { baseUserDomain + "userRegion" } } //请求二级域名

var NV_Login: String { get { baseUserDomain + "user" } }  //手机注册

var NV_Login_Email: String { get { baseUserDomain + "user_e" } }  //邮箱注册

var NV_Logout: String { get { baseUserDomain + "user_out" } }

var NV_SMS_Code: String { get { baseServiceDomain + "sms_p" } }

var NV_Email_Code: String { get { baseServiceDomain + "sms_e" } }

var NV_Verify_Token: String { get { baseUserDomain + "user_t" } }

var NV_Update_LoginPwd: String { get { baseUserDomain + "user" + "?account=%@&id=%@&verify=%@&pass=%@" } }

/** 事件列表 */
var NV_Events: String { get { baseEventDomain + "devMess" } }

var NV_Events_Dates: String { get { baseEventDomain + "devMessDates" } }

/** 设备列表 */
var NV_Devices: String { get { baseDeviceDomain + "devices"} }  //获取用户的所有设备

var NV_Devices_Filter: String { get { baseDeviceDomain + "devices_r"} }  //筛选用户的主设备和分享设备

var NV_Devices_Unbind: String { get { baseDeviceDomain + "device" + "?did=%@&role=%@&uid=%@&accessId=%@&tid=%@" } }

var NV_Devices_ModifyName: String { get { baseDeviceDomain + "device" + "?did=%@&devName=%@" } }

var NV_Devices_Share: String { get { baseDeviceDomain + "device_s" } }

/** 设备配网 */
var NV_Device_Bind: String { get { baseDeviceDomain + "bind_d" } }

var NV_Device_Bind_4g: String { get { baseDeviceDomain + "bind_d_4g" } }

/** 用户相关 */
var NV_User_Image: String { get { baseUserDomain + "user_img" } }

//上传推送token
var NV_User_PushToken: String { get { baseUserDomain + "pushToken?id=%@&token=%@" } }

var NV_User_ShareMessage: String { get { baseShareMessageDomain + "shareMess" } }

var NV_User_ShareMessageAction: String { get { baseShareMessageDomain + "shareMess?choose=%@&did=%@&host_uid=%@&share_uid=%@&sid=%@" } }

var NV_User_ShareList: String { get { baseDeviceDomain + "shares" } }

var NV_User_Unshare: String { get { baseDeviceDomain + "device_us" } }

var NV_User_ShowMall: String { get { baseDomain + "appVersion/check_m" } }

var NV_User_Check_Version: String { get { baseDomain + "appVersion/appversion" } }

var NV_User_Newest_ShareMsg: String { get { baseShareMessageDomain + "shareMess_li" } }

var NV_User_Do_Not_Disturb: String { get { baseUserDomain + "setDisturbTime" } }

var NV_User_Get_Do_Not_Disturb: String { get { baseUserDomain + "getDisturbTime" } }

/* 云存 */
var NV_Cloud_CloudPackages: String { get { baseServiceDomain + "cloudServices" } }

var NV_Cloud_WXPay: String { get { basePayDomain + "wxPayOrder" } }

var NV_Cloud_ALiPay: String { get { basePayDomain + "aliPayOrder" } }

var NV_Cloud_Paypal: String { get { basePayDomain + "getPayPalToken" } }

var NV_Cloud_Free: String { get { basePayDomain + "free_cloud" } }

var NV_Cloud_PaypalRes: String { get { basePayDomain + "payPalPay" } }

var NV_Cloud_CheckPayRes: String { get { basePayDomain + "pay_result" } }

var NV_Cloud_DeviceLast: String { get { baseCloudDomain + "cloudOrder_l_t" } }

var NV_Cloud_AllOrderList: String { get { baseCloudDomain + "cloudOrders_t" } }

var NV_Cloud_DeviceOrderList: String { get { baseCloudDomain + "cloudOrders_d_t" } }

/* 4G流量 */
/// 获取可购买的4G流量套餐
var NV_Cellular_Packages: String { get { baseCellularDomain + "get_package_manage" } }

///MARK - 单个设备的流量购买记录
var NV_Cellular_RenewList: String { get { baseCellularDomain + "get_device_renew_list" } }

///MARK - 当前套餐的用量数据
var NV_Cellular_CurrentUsage: String { get { baseCellularDomain + "get_device_current_package_usage" } }

///MARK - 查询iccid指定月份每日使用量
var NV_Cellular_MonthlyForm: String { get { baseCellularDomain + "usagelog" } }


/// 本地调试web
let NV_Test_Web: String = "http://192.168.33.142:5500/%@"
