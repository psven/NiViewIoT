//
//  NVNetworkManager.swift
//  NiViNV
//
//  Created by nice on 2020/6/28.
//  Copyright © 2020 nice. All rights reserved.
//

import UIKit
import Alamofire

typealias ResponseHandler = (_ response: Response) -> Void


class NVNetworkingManager: NSObject {
     
    //证书
    static let certDataString = "MIIEMjCCAxqgAwIBAgIBATANBgkqhkiG9w0BAQUFADB7MQswCQYDVQQGEwJHQjEbMBkGA1UECAwSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHDAdTYWxmb3JkMRowGAYDVQQKDBFDb21vZG8gQ0EgTGltaXRlZDEhMB8GA1UEAwwYQUFBIENlcnRpZmljYXRlIFNlcnZpY2VzMB4XDTA0MDEwMTAwMDAwMFoXDTI4MTIzMTIzNTk1OVowezELMAkGA1UEBhMCR0IxGzAZBgNVBAgMEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBwwHU2FsZm9yZDEaMBgGA1UECgwRQ29tb2RvIENBIExpbWl0ZWQxITAfBgNVBAMMGEFBQSBDZXJ0aWZpY2F0ZSBTZXJ2aWNlczCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAL5AnfRu4ep2hxxNRUSOvkbIgwadwSr+GB+O5AL686tdUIoWMQuaBtDFcCLNSS1UY8y2bmhGC1Pqy0wkwLxyTurxFa70VJoSCsN6sjNg4tqJVfMiWPPe3M/vg4aijJRPn2jymJBGhCfHdr/jzDUsi14HZGWCwEiwqJH5YZ92IFCokcdmtet4YgNW8IoaE+oxox6gmf049vYnMlhvB/VruPsUK6+3qszWY19zjNoFmag4qMsXeDZRrOme9Hg6jc8P2ULimAyrL58OAd7vn5lJ8S3frHRNG5i1R8XlKdH5kBjHYpy+g8cmez6KJcfA3Z3mNWgQIJ2P2N7Sw4ScDV7oL8kCAwEAAaOBwDCBvTAdBgNVHQ4EFgQUoBEKIz6W8Qfs4q8p74Klf9AwpLQwDgYDVR0PAQH/BAQDAgEGMA8GA1UdEwEB/wQFMAMBAf8wewYDVR0fBHQwcjA4oDagNIYyaHR0cDovL2NybC5jb21vZG9jYS5jb20vQUFBQ2VydGlmaWNhdGVTZXJ2aWNlcy5jcmwwNqA0oDKGMGh0dHA6Ly9jcmwuY29tb2RvLm5ldC9BQUFDZXJ0aWZpY2F0ZVNlcnZpY2VzLmNybDANBgkqhkiG9w0BAQUFAAOCAQEACFb8AvCb6P+k+tZ7xkSAzk/ExfYAWMymtrwUSWgEdujm7l3sAg9g1o1QGE8mTgHj5rCl7r+8dFRBv/38ErjHT1r0iWAFf2C3BUrz9vHCv8S5dIa2LX1rzNLzRt0vxuBqw8M0Ayx9lt1awg6nCpnBBYurDC/zXDrPbDdVCYfeU0BsWO/8tqtlbgT2G9w84FoVxp7Z8VlIMCFlA2zs6SFz7JsDoeA3raAVGI/6ugLOpyypEBMs1OUIJqsil2D4kF501KKaU73yqWjgom7C12yxow+ev+to51byrvLjKzg6CYG1a4XXvi3tPxq3smPi9WIsgtRqAEFQ8TmDn5XpNpaYbg=="
    
    static let ShareInstance = NVNetworkingManager()
    
    private lazy var trustManager: ServerTrustManager = {
        
        let certificates: [SecCertificate] = [NVCertificates.rootCA]
        let trustPolicy = PinnedCertificatesTrustEvaluator(certificates: certificates, acceptSelfSignedCertificates: true)
        
        let tmpManager = ServerTrustManager(evaluators: ["test-cn.niceviewer.com": trustPolicy,
                                                         "test-en.niceviewer.com": trustPolicy,
                                                         "cloud-nc.niceviewer.com": trustPolicy,
                                                         "cloud-cn1.niceviewer.com": trustPolicy,
                                                         "cloud-us1.niceviewer.com": trustPolicy,
                                                         "cloud-eur1.niceviewer.com": trustPolicy,
                                                         "cloud-ap1.niceviewer.com": trustPolicy,
                                                         "cloud.niceviewer.com": trustPolicy,
                                                         "172.16.1.56": DisabledTrustEvaluator()])
        return tmpManager
    }()
    
    private lazy var manager: Session = {
        let config: URLSessionConfiguration = URLSessionConfiguration.af.default
        config.httpAdditionalHeaders = NVHttpHeaders
        config.timeoutIntervalForRequest = NVTimeout
        //根据config创建manager
        return Session(configuration: config,
                       delegate: SessionDelegate(),
                       serverTrustManager: trustManager)
    }()
    
    //配网专用
    private lazy var deviceBindManager: Session = {
        let config: URLSessionConfiguration = URLSessionConfiguration.af.default
        config.httpAdditionalHeaders = NVHttpHeaders
        config.timeoutIntervalForRequest = 60
        return Session(configuration: config,
                       delegate: SessionDelegate(),
                       serverTrustManager: trustManager)
    }()
    
    private lazy var m3u8Manager: Session = {
        let config: URLSessionConfiguration = URLSessionConfiguration.af.default
        config.timeoutIntervalForRequest = 15
        
        let tempManager = Session(configuration: config, delegate: SessionDelegate())
        
        return tempManager
    }()
    
    ///MARK 创建SecCertificate
    private struct NVCertificates {
        static let rootCA = NVCertificates.certificate()
        
        static func certificate() -> SecCertificate {
            let data = Data.init(base64Encoded: certDataString, options: [])
            let certificate = SecCertificateCreateWithData(nil, data! as CFData)
            return certificate!
        }
    }
    
    ///baseURL,可以通过修改来实现切换开发环境与生产环境
    private var NVPrivateNetworkBaseUrl: String?
    ///默认超时时间
    private var NVTimeout: TimeInterval = 15
    /**** 请求header
     *  根据后台需求,如果需要在header中传类似token的标识
     *  就可以通过在这里设置来实现全局使用
     *  这里是将token存在keychain中,可以根据自己项目需求存在合适的位置.
     */
    private var NVHttpHeaders: [String:String]? {
        let timestamp = "\(Date().milliStamp)".aesEncode()
        
        var headers = ["Content-type": "application/json;charset=utf-8",
                       "timestamp": timestamp,
                       "Accept": "application/json",
                       "app-name": kAPPBundleName.lowercased(),
                       "app-lang": getCurrentLanguage()]
        
        if kUserToken.length > 0 {
            headers["token"] = kUserToken.aesEncode()
        }
        
        return headers
    }
    ///缓存存储地址
    private let cachePath = NSHomeDirectory() + "/Documents/AlamofireCaches/"

    ///核心方法
    func request(_ api: NVApi, responseHandler: @escaping ResponseHandler) {
        
        let url = encodingURL(path: api.url)
        
        var requestManager: Session
        if url.containsIgnoringCase(find: "bind_d") {
            requestManager = deviceBindManager
        } else if url.containsIgnoringCase(find: "m3u8") {
            requestManager = m3u8Manager
        } else {
            requestManager = manager
        }
        
        let method = HTTPMethod(rawValue: api.method)
        
        let startDate = Date()
        // TODO: get 缓存处理
        if method == .get {
            
        }
        
        NVNetworkLog("🟡====== Network Begin ======")
        NVNetworkLog("🟡URL:\(url)")
        NVNetworkLog("🟡Header:\(api.headers)")
        NVNetworkLog("🟡Parameters:\(api.parameters ?? [:])")
        
        requestManager.request(url, method: method, parameters: api.parameters, encoding: api.encoding, headers: HTTPHeaders(api.headers))
            .responseJSON { response in
                let endDate = Date()
                let r = Response(response: response)
                // log
                NVNetworkLog("🟡Time Cost:\(fabs(startDate.timeIntervalSince(endDate)))")
                
                if let url = response.request?.url { 
                    NVNetworkLog("🟡AbsoluteURL: \(url.absoluteURL)")
                }
                
                if let json = r.json {
                    NVNetworkLog("🟢Response:\(json)")
                }
                if let error = r.error {
                    NVNetworkLog("🔴Error:\(error)")
                }
                NVNetworkLog("🟡====== Network End ======")
                responseHandler(r)
                
                if r.code == .invalidToken {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        NVEnvironment.shared.update(token: "")
                        NVEnvironment.shared.resetCurrentDomain()
                    }
                }
                            
        }
    }
}
// MARK: 缓存数据相关
extension NVNetworkingManager {
    ///从缓存中获取数据
    func cahceResponseWithURL(url: String, paramters: [String: Any]?) -> Any? {
        guard let uid = paramters?["uid"] as? String, kUserID == uid else {
            return nil
        }
        var cacheData: Any?
        let directorPath = cachePath
        let absoluteURL = self.generateGETAbsoluteURL(url: url, paramters)
        ///使用md5进行加密
        let key = absoluteURL.md5()
        let path = directorPath.appending(key)
        let data: Data? = FileManager.default.contents(atPath: path)
        if data != nil {
            cacheData = data
            NVLog("Read data from cache for url: \(url)\n")
        }
        return cacheData
    }
    /// 进行数据缓存
    ///
    /// - Parameters:
    ///   - responseObject: 缓存数据
    ///   - request: 请求
    ///   - parameters: 参数
    func cacheResponseObject(responseObject: AnyObject,
                                    request: URLRequest,
                                    parameters: [String: Any]?) {
        if !(responseObject is NSNull) {
            let directoryPath: String = cachePath
            ///如果没有目录,那么新建目录
            if !FileManager.default.fileExists(atPath: directoryPath, isDirectory: nil) {
                do {
                    try FileManager.default.createDirectory(atPath: directoryPath,
                                                            withIntermediateDirectories: true,
                                                            attributes: nil)
                } catch let error {
                    NVLog("create cache dir error: " + error.localizedDescription + "\n")
                    return
                }
            }
            ///将get请求下的参数拼接到url上
            let absoluterURL = self.generateGETAbsoluteURL(url: (request.url?.absoluteString)!, parameters)
            ///对url进行md5加密
            let key = absoluterURL.md5()
            ///将加密过的url作为目录拼接到默认路径
            let path = directoryPath.appending(key)
            ///将请求数据转换成data
            let dict: AnyObject = responseObject
            var data: Data?
            do {
                try data = JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            } catch {
            }
            ///将data存储到指定路径
            if data != nil {
                let isOk = FileManager.default.createFile(atPath: path,
                                                          contents: data,
                                                          attributes: nil)
                if isOk {
                    NVLog("cache file ok for request: \(absoluterURL)\n")
                } else {
                    NVLog("cache file error for request: \(absoluterURL)\n")
                }
            }
        }
    }
}
// MARK: url拼接相关
extension NVNetworkingManager {
    ///中文路径encoding
    func encodingURL(path: String) -> String {
        return path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    }
    /// 在url最后添加一部分,这里是添加的选择语言,可以根据需求修改.
    func buildAPIString(path: String) -> String {
        if path.containsIgnoringCase(find: "http://")
            || path.containsIgnoringCase(find: "https://") {
            return path
        }
        let lang = "zh_CN"
        var str = ""
        if path.containsIgnoringCase(find: "?") {
            str = path + "&@lang=" + lang
        } else {
            str = path + "?@lang=" + lang
        }
        return str
    }
    /// get请求下把参数拼接到url上
    func generateGETAbsoluteURL(url: String, _ params: [String: Any]?) -> String {
        guard let params = params else {return url}
        if params.count == EMPTY {
            return url
        }
        var url = url
        var queries = ""
        for key in (params.keys) {
            let value = params[key]
            if value is [String: Any] {
                continue
            } else if value is [Any] {
                continue
            } else if value is Set<AnyHashable> {
                continue
            } else {
                let paramStr = key == "role"
                ? key + "=" + (value as! String)
                : key + "=" + "\((value as? String)?.aesEncode() ?? "")"
                queries += paramStr + (params.keys.count > 1 ? "&" : "")
            }
        }
        if queries.length > 1 {
            queries = String(queries[queries.startIndex..<queries.endIndex])
        }
        if (url.hasPrefix("http://") || url.hasPrefix("https://") && queries.length > 1) {
            if url.containsIgnoringCase(find: "?") || url.containsIgnoringCase(find: "#") {
                url = "\(url)\(queries)"
            } else {
                url = "\(url)?\(queries)"
            }
        }
        return url.length == 0 ? queries : url
    }
}

extension NVNetworkingManager {
    ///get请求
//    func getData(url: String,
//                     params: [String: Any]?,
//                     needCache: Bool = false,
//                    success: @escaping NVResponseSuccess,
//                    failure: @escaping NVResponseFail) {
//
//        let newUrl = self.generateGETAbsoluteURL(url: url, params)
//
//        NVNetworkingManager.ShareInstance.requestWith(url: newUrl, httpMethod: .get, params: nil, success: { (response) in
//            self.handleResponse(response) { (resDict) in
//                success(resDict as AnyObject)
//                if needCache {
//                    self.cacheResponseObject(responseObject: resDict as AnyObject, request: URLRequest.init(url: URL.init(string: url)!), parameters: params)
//                }
//            } failure: { (obj) in
//                if let cacheData = self.cahceResponseWithURL(url: url, paramters: params) as? Data, let cacheDict = cacheData.toDictionary() {
//                    success(cacheDict as AnyObject)
//                } else {
//                    failure(obj)
//                }
//            }
//
//        }, error: { (error) in
//            if let cacheData = self.cahceResponseWithURL(url: url, paramters: params) as? Data, let cacheDict = cacheData.toDictionary() {
//                success(cacheDict as AnyObject)
//            } else {
//                failure(error)
//            }
//        })
//    }
    
    /// MARK - 图片上传
    ///
    /// - Parameters:
    ///   - url: 地址
    ///   - image: 图片
    ///   - params: 参数
    ///   - imageName: 图片名字
    ///   - isShowHud: 是否显示HUD
    ///   - progressClosure: 进度回调
    ///   - successClosure: 成功回调
    func uploadImage(api: NVApi,
                     progressClosure:@escaping((_ progress:Double) ->Void),
                     successClosure:@escaping((_ result:[String:AnyObject]) -> ()))
    {
        guard case let .userImage(uid, image) = api else {
            return
        }
        uploadImage(
            url: api.url,
            image: image,
            params: ["uid" : String(uid)],
            imageName: "\(uid)\(Date().milliStamp)",
            progressClosure: progressClosure, successClosure: successClosure
        )
    }
    
    /// MARK - 图片上传
    ///
    /// - Parameters:
    ///   - url: 地址
    ///   - image: 图片
    ///   - params: 参数
    ///   - imageName: 图片名字
    ///   - isShowHud: 是否显示HUD
    ///   - progressClosure: 进度回调
    ///   - successClosure: 成功回调
    func uploadImage(url: String,
                     image: UIImage,
                     params: [String:String],
                     imageName:String,
                     progressClosure:@escaping((_ progress:Double) ->Void),
                     successClosure:@escaping((_ result:[String:AnyObject]) -> ()))
    {
      //压缩图片 可自定义
        let imageData : Data = image.jpegData(compressionQuality: 0.8)!
        
                
        AF.upload(multipartFormData: { (multiPart) in
            for p in params {
                multiPart.append(p.value.aesEncode().data(using: String.Encoding.utf8)!, withName: p.key)
            }
            multiPart.append(imageData, withName: "file", fileName: "\(imageName).jpg", mimeType: "image/jpeg")
        }, to: url, usingThreshold: MultipartFormData.encodingMemoryThreshold, method: .post, headers: HTTPHeaders.init(NVHttpHeaders!), interceptor: nil, fileManager: .default, requestModifier: nil).uploadProgress(queue: .main, closure: { progress in
             
        }).response { (response) in
            switch response.result {
            case .success(let dataObj):
                
                if var dict = dataObj?.toDictionary(), dict["code"] as? Int == 0, let jsonStr = dict["data"] as? String {
                    let dataStr: String = jsonStr.aesDecode()
                    dict["data"] = dataStr.stringValueDic()
                    successClosure(dict as [String: AnyObject])
                } else {
                    
                }

            case .failure(let err):
                NVLog("upload err: \(err)")
            }
        }

    }
}

extension NVNetworkingManager {
    
    //根据是否有二级域名进行下一步操作
    func getSecondDomain(for account: String, completedHandle: @escaping () -> Void) {
        // 重置二级域名，防止出现`其他用户退出登录后，登录新的账号，但是新账号服务器接口不会返回匹配的二级域名，这时二级域名没有更新，还是用的上一个账号的，导致新用户注册不了`的情况，比如：上一个账号是中国域名，退出后注册美国账号
        NVEnvironment.shared.resetCurrentDomain()
        if let domain = NVEnvironment.shared.domain(for: account) {
            NVEnvironment.shared.update(currentDomain: domain)
            completedHandle()
        } else {
            //请求二级域名并保存
            let api = NVApi.userRegion(account: account)
            NVNetworkingManager.ShareInstance.request(api) { response in
                
                if let dataDict = response.data as? [String: Any],
                   let domain = dataDict["serverDomain"] as? String,
                   let resAccount = dataDict["account"] as? String,
                   resAccount == account {
                    NVEnvironment.shared.update(domain: domain, for: account)
                    NVEnvironment.shared.update(currentDomain: domain)
                }
                completedHandle()
            }
        }
    }
}
