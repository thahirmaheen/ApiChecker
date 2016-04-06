//
//  Model.swift
//  OneApp
//
//  Created by Thahir Maheen on 05/02/16.
//  Copyright © 2016 FAYA. All rights reserved.
//

import Foundation

class Model {
    
    class var sharedModel: Model {
        struct Singleton {
            static let instance = Model()
        }
        
        return Singleton.instance
    }
    
    var parseEngine = ParseEngine(baseURL: NSURL(string: "http://oneapp.fayastage.com"))

    var baseURL: String {
        get {
            return NSUserDefaults.standardUserDefaults().valueForKey(UserDefaults.BaseUrl) as? String ?? ""
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKeyPath: UserDefaults.BaseUrl)
            parseEngine = ParseEngine(baseURL: NSURL(string: newValue))
        }
    }
    
    var basicUserName: String {
        get {
            return NSUserDefaults.standardUserDefaults().valueForKey(UserDefaults.BasicUserName) as? String ?? ""
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKeyPath: UserDefaults.BasicUserName)
        }
    }
    
    var basicPassword: String {
        get {
            return NSUserDefaults.standardUserDefaults().valueForKey(UserDefaults.BasicPassword) as? String ?? ""
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKeyPath: UserDefaults.BasicPassword)
        }
    }
    
    var bearerToken: String {
        get {
            return NSUserDefaults.standardUserDefaults().valueForKey(UserDefaults.BearerToken) as? String ?? ""
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKeyPath: UserDefaults.BearerToken)
        }
    }
    
    var keyPath: String {
        get {
            return NSUserDefaults.standardUserDefaults().valueForKey(UserDefaults.KeyPath) as? String ?? ""
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKeyPath: UserDefaults.KeyPath)
        }
    }
    
    var parameters: [String: String] {
        get {
            return NSUserDefaults.standardUserDefaults().valueForKey(UserDefaults.Parameters) as? [String: String] ?? [:]
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKeyPath: UserDefaults.Parameters)
        }
    }
    
    func processAPI(method: Method, keyPath: String, params: [String: String], completionHandler: (output: String) -> Void) {
        switch method {
        case .GET:
            parseEngine.fetchData(keyPath, params: params, shouldShowHUD: true) { (data, error) in
                if error != nil {
                    completionHandler(output: "API Failed with error \(error)")
                    return
                }
                
                completionHandler(output: data?.description ?? "")
            }
        case .POST:
            parseEngine.postData(keyPath, params: params, shouldShowHUD: true) { (data, error) in
                if error != nil {
                    completionHandler(output: "API Failed with error \(error)")
                    return
                }
                
                completionHandler(output: data?.description ?? "")
            }
        case .PATCH:
            parseEngine.patchData(keyPath, params: params, shouldShowHUD: true) { (data, error) in
                if error != nil {
                    completionHandler(output: "API Failed with error \(error)")
                    return
                }
                
                completionHandler(output: data?.description ?? "")
            }
        case .MULTIPARTPOST:
            parseEngine.postMultiPartData(keyPath, params: params){ (data, error) in
                if error != nil {
                    completionHandler(output: "API Failed with error \(error)")
                    return
                }
                
                completionHandler(output: data?.description ?? "")
            }
        }
    }
    
    struct UserDefaults {
        static let BaseUrl = "kBaseUrl"
        static let BasicUserName = "kBasicUserName"
        static let BasicPassword = "kBasicPassword"
        static let BearerToken = "kBearerToken"
        static let KeyPath = "kKeyPath"
        static let Parameters = "kParameters"
     }
}