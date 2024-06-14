//
//  NVUserData.swift
//  NIot
//
//  Created by apple on 2021/11/23.
//

import UIKit

class NVEnvironment {
    
    struct Constant {
        static let kPrefix = "NIotPrivate_"
        static let kDomainMapping = kPrefix + "domainMappings"
        static let kCurrentDomain = kPrefix + "currentDomain"
    }
    
    static let shared = NVEnvironment()
    
    private(set) var appName: String?
    private(set) var appLanguage: NIotNetConfigLanguage?
    private(set) var secretId: String?
    private(set) var secretKey: String?
    
    private(set) var token: String?
    private(set) var pushToken: String = ""
//    private(set) var userName: String?
    private(set) var currentDomain = "cloud-nc.niceviewer.com"
    
    private var _domainMappings = [String: String]()
    
    
    init() {
        if let mapping = UserDefaults.standard.dictionary(forKey: Constant.kDomainMapping) as? [String: String] {
            _domainMappings = mapping
        }
        if let domain = UserDefaults.standard.string(forKey: Constant.kCurrentDomain) {
            currentDomain = domain
        }
    }
    
    open func setup(appName: String, appLanguage: NIotNetConfigLanguage, secretId: String, secretKey: String) {
        self.appName = appName
        self.appLanguage = appLanguage
        self.secretId = secretId
        self.secretKey = secretKey
    }
    
    func update(appLanguage: NIotNetConfigLanguage) {
        self.appLanguage = appLanguage
    }
    
    func update(token: String) {
        self.token = token
    }
    
    func update(pushToken: String) {
        self.pushToken = pushToken
    }
    
    func domain(for user: String) -> String? {
        return _domainMappings[user]
    }
    
    func update(domain: String, for user: String) {
        _domainMappings[user] = domain
        persistData()
    }
    
    func update(currentDomain: String) {
        self.currentDomain = currentDomain
        persistData()
    }
    
    func resetCurrentDomain() {
        update(currentDomain: "cloud-nc.niceviewer.com")
    }
    
    private func persistData() {
        UserDefaults.standard.set(currentDomain, forKey: Constant.kCurrentDomain)
        UserDefaults.standard.set(_domainMappings, forKey: Constant.kDomainMapping)
        UserDefaults.standard.synchronize()
    }
}
