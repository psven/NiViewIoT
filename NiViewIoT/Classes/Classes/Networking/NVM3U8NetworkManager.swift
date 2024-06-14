//
//  NVM3U8NetworkManager.swift
//  NiView
//
//  Created by nice on 2021/1/22.
//  Copyright © 2021 nice. All rights reserved.
//

import UIKit
import AFNetworking

class NVM3U8NetworkManager: NSObject {
    static let share = NVM3U8NetworkManager()
    
    private lazy var manager: AFHTTPSessionManager = {
        let mgr = AFHTTPSessionManager()
        mgr.requestSerializer = AFJSONRequestSerializer()
        mgr.securityPolicy = AFSecurityPolicy.init(pinningMode: .none)
        mgr.securityPolicy.allowInvalidCertificates = true
        mgr.securityPolicy.validatesDomainName = false
        mgr.responseSerializer = AFHTTPResponseSerializer()
        return mgr
    }()
    
    public func get(_ urlStr: String, parameters: [String: Any]?, success: ((Any?) -> Void)?, failure: ((Error) -> Void)?) {
        manager.get(urlStr, parameters: parameters, headers: nil, progress: nil) { (task, response) in
            if let data = response as? Data {
                let dataStr = String(data: data, encoding: .utf8)
                success?(dataStr)
            }
        } failure: { (task, error) in
            failure?(error)
        }

    }
    
    public func download(_ urlStr: String, progress: ((Progress) -> Void)?, saveTo: String, completionHandler: ((URLResponse, Error?) -> Void)?) {
        guard let url = URL(string: urlStr) else {
            return
        }
        let urlRequest = URLRequest.init(url: url)
        
        manager.downloadTask(with: urlRequest, progress: progress) { (url, resp) -> URL in
            URL(string: saveTo)!
        } completionHandler: { (response, url, error) in
            completionHandler?(response, error)
        }

    }
}
