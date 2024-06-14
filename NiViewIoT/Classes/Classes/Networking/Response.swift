//
//  Response.swift
//  NIot
//
//  Created by apple on 2021/11/18.
//

import UIKit
import Alamofire

@objc
enum NVStatusCode: Int {
    
    case success = 0
    
    case failure = -1
    
    case invalidToken = -401
    
    case forbidden = -403
    
    case serviceBusy = -429
    /// 邮件发送失败
    case emailSendingError = -4004
    /// 时间戳校验失败
    case invalidTimestamp = -4010
    /// 请求参数不能为空
    case emptyParameterError = -4011
    /// 验证码已失效
    case invalidSMSCode = -4012
    /// 验证码错误
    case wrongSMSCode = -4013
    /// 邮箱正则匹配失败
    case emailRegularMatchesFailed = -4015
    /// 请求参数不合法
    case invalidParameter = -4016
    /// 请求参数类型不正确
    case invalidParameterType = -4017
    /// 账号或密码错误
    case invalidAccountOrPwd = -4019
    /// 超时
    case timeout = -4023
    /// 设备已被其他用户绑定
    case deviceAlreadyBoundError = -4026
    /// 不是当前设备的主用户
    case notMainUserForCurrentDeviceError = -4027
    /// 分享用户不存在
    case sharingUserDoesNotExistError = -4028
    /// 图片格式不正确
    case invalidImageFormat = -4029
    /// 无法分享给自己
    case shareToUserSelfError = -4031
    /// 设备已经被解绑
    case deviceAlreadyUnbindError = -4032
    /// 设备未准备
    case deviceNotReadyError = -4033
    /// 已经分享过了,等待被分享用户接受
    case sharingWaitToBeAcceptedError = -4037
    /// 分享消息已过期
    case sharinMessageExpiredError = -4038
    /// 分享用户已存在
    case alreadySharedError = -4040
    /// 最多只能与8位用户共享设备
    case sharingNumberLimitError = -4041
    /// 注册用户不在当前服务器
    case userNotAtCurrentServerError = -4043
    
    // MARK: - Private
    
    /// 网络异常
    case fileNotFound = 404
    /// 未知错误
    case otherError = -1111
    /// 网络异常
    case networkError = 9999
    //api error msg
//    "-429" = "Service is busy, please try again later";
//    "-4012" = "Verification code error";
//    "-4013" = "Verification code error";
//    "-4019" = "Account or password error";
//    "-4022" = "Device ID does not exist, please contact with the after-sales team.";
//    "-4026" = "The device has bound to by other user, please contact with the device user or after-sales team to unbind:";
//    "-4023" = "Network Configure time out, please check the network and retry in later.";
//    "-4028" = "Sharing user does not exist";
//    "-4031" = "Can not share to user self.";
//    "-4037" = "Sharing, waiting to be accepted by shared users";
//    "-4040" = "Already shared the device with active user";
//    "-4041" = "Sharing number of devices has reached limit.";
//    "-4032" = "Operation failed, the device has unbound";
//    "-4038" = "The sharing message has expired";
//    "-4035" = "Single day verification code delivery has reached limit, please try again tomorrow";
//    "-4039" = "Verification codes are sent too frequently. Please try again after one minute";
//    "-4046" = "This device does not currently support use in the area where the current account is registered";

}

@objcMembers
public class NVError: NSError {
    
    init(code: Int, errorMsg: String) {
        super.init(domain: "com.niceview.network", code: code, userInfo: [NSLocalizedDescriptionKey: errorMsg])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class Response {
    
    var code: NVStatusCode = .success
    var message = ""
    var json: [String: Any]?
    var data: AnyObject?
    
    var error: Error?

    var isSuccess: Bool {
        return code == .success
    }
    var isError: Bool {
        return !isSuccess
    }

    init(response: AFDataResponse<Any>) {
        guard let json = response.value as? [String: Any],
              let code = json["code"] as? Int
        else {
            if let statusCode = response.response?.statusCode {
                switch statusCode {
                case 401:
                    self.code = .invalidToken
                case 404:
                    self.code = .fileNotFound
                    self.message = "路径错误"
                case 500:
                    self.code = .networkError
                    self.message = "服务器内部错误"
                // TODO: API里新增一个接口，针对个别接口，比如上传token等静默调用的不提示，启动页提示后跳登陆页
                case 429, 529:
                    self.code = .serviceBusy
                    self.message = "服务繁忙"
                default:
                    self.code = .networkError
                    self.message = "当前网络不可用，请检查网络设置"
                }
                if let error = response.error {
                    self.error = error
                } else {
                    self.error = NVError(code: statusCode, errorMsg: message)
                }
            }
            return
        }
            
        // message
        if let message = json["msg"] as? String {
            self.message = message
        }
        if let message = json["message"] as? String {
            self.message = message
        }
        
        // code
        self.code = NVStatusCode(rawValue: code) ?? .otherError
        
        if self.code != .success {
            self.error = NVError(code: code, errorMsg: message)
        }
        
        // AES decode
        if let data = json["data"] as? String {
            let dataStr = data.aesDecode()
            if let dict = dataStr.stringValueDic() {
                self.data = dict as AnyObject
            } else if let array = stringValueArray(jsonString: dataStr) {
                self.data = array as AnyObject
            } else {
                self.data = dataStr as AnyObject
            }
        } else {
            self.data = json["data"] as AnyObject
        }
        
        self.json = json
        self.json?["data"] = self.data
    }
    
}
