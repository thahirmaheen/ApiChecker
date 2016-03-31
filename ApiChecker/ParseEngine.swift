//
//  ParseEngine.swift
//  OneApp
//
//  Copyright (c) 2015 digitalbrandgroup. All rights reserved.
//  Created by Thahir Maheen on 13/08/15.
//

import Foundation
import AFNetworking
import SVProgressHUD

extension NSMutableData {
    
    func appendString(string: String) {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        appendData(data!)
    }
}

//let baseUrl = "http://oneapp.fayastage.com"

class ParseEngine: AFHTTPSessionManager {
    
    var baseUrl: String {
        return Model.sharedModel.baseURL
    }
    
    class var sharedEngine: ParseEngine {
        struct Singleton {
            static let sharedEngine = ParseEngine(baseURL: NSURL(string: Model.sharedModel.baseURL), sessionConfiguration: NSURLSessionConfiguration.defaultSessionConfiguration())
        }
        return Singleton.sharedEngine
    }
    
    override init(baseURL url: NSURL!, sessionConfiguration configuration: NSURLSessionConfiguration!) {
        super.init(baseURL: url, sessionConfiguration: configuration)
        
        // set serializers
        requestSerializer = AFJSONRequestSerializer()
        responseSerializer = AFJSONResponseSerializer()
        
        // set basic authorization
        setBasicAuthorization()
        
        // start network reachability checks
        AFNetworkReachabilityManager.sharedManager().startMonitoring()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    let networkReachabilityError = NSError(domain: "ATC.Reachability", code: 100, userInfo: ["title": "alert_title_network_unreachable", "message": "alert_message_network_unreachable"])
    
    func setBasicAuthorization() {
        requestSerializer.setAuthorizationHeaderFieldWithUsername(Model.sharedModel.basicUserName, password: Model.sharedModel.basicPassword)
    }
    
    func setBearerAuthorization() {
        requestSerializer.setValue(Model.sharedModel.bearerToken, forHTTPHeaderField: "Authorization")
    }
    
    func fetchData(keyPath: String = "", params: [String: String] = [:], shouldShowHUD: Bool = false, completionHandler: (data: NSDictionary?, error: NSError?) -> ()) {
        
        if !AFNetworkReachabilityManager.sharedManager().reachable {
            
            UIAlertView(title: "alert_title_network_unreachable", message: "alert_message_network_unreachable", delegate: nil, cancelButtonTitle: "cancel").show()
            
            // no network
            print("no network connection")
            completionHandler(data: nil, error: networkReachabilityError)
            return
        }
        
        if shouldShowHUD { SVProgressHUD.show() }
        
        GET(keyPath, parameters: params, success: { (dataTask, data) in
            
            print("response is \(data)")
            
            // handle errors if any
            let dictionaryData = data as! NSDictionary
            if let metaData = dictionaryData["meta"] as? [String : AnyObject] {
                let meta = Meta(data: metaData)
                
                if meta.code != 200 {
                    // configure error
                    let error = NSError(domain: "", code: meta.code, userInfo: nil)
                    dispatch_async(dispatch_get_main_queue()) {
                        SVProgressHUD.dismiss()
                        completionHandler(data: nil, error: error)
                    }
                    return
                }
            }
            else { print("XXX no meta found, fix api") }
            
            dispatch_async(dispatch_get_main_queue()) {
                SVProgressHUD.dismiss()
                completionHandler(data: dictionaryData, error: nil)
            }
            }, failure: { (dataTask, error) in
                
                SVProgressHUD.dismiss()
                
                // customize the error here
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler (data: nil, error: error)
                }
        })
    }
    
    func postData(keyPath: String = "", params: [String: String] = [:], shouldShowHUD: Bool = false, completionHandler:(data: NSDictionary?, error: NSError?) -> ()) {
        
        if !AFNetworkReachabilityManager.sharedManager().reachable {
            
            UIAlertView(title: "alert_title_network_unreachable", message: "alert_message_network_unreachable", delegate: nil, cancelButtonTitle: "cancel").show()
            
            // no network
            print("no network connection")
            completionHandler(data: nil, error: networkReachabilityError)
            return
        }
        
        if shouldShowHUD { SVProgressHUD.show() }
        
        POST(keyPath, parameters: params, success: { (dataTask, data) in
            
            SVProgressHUD.dismiss()
            
            print("response is \(data)")
            
            // handle errors if any
            let dictionaryData = data as! NSDictionary
            if let metaData = dictionaryData["meta"] as? [String : AnyObject] {
                let meta = Meta(data: metaData)
                
                if meta.code != 200 {
                    // configure error
                    let error = NSError(domain: "", code: meta.code, userInfo: nil)
                    dispatch_async(dispatch_get_main_queue()) {
                        completionHandler(data: nil, error: error)
                    }
                    return
                }
            }
            else { print("XXX no meta found, fix api") }
            
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(data: data as? NSDictionary, error: nil)
            }
            
            }, failure: { (dataTask, error) in
                
                SVProgressHUD.dismiss()
                
                // customize the error here
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler (data: nil, error: error)
                }
        })
    }
    
    func postMultiPartData(keyPath: String = "", params: [String: String] = [:], isBasicAuthorization: Bool = false, shouldShowHUD: Bool = false, completionHandler:(data: NSDictionary?, error: NSError?) -> ()) {
        
        if !AFNetworkReachabilityManager.sharedManager().reachable {
            
            UIAlertView(title: "alert_title_network_unreachable", message: "alert_message_network_unreachable", delegate: nil, cancelButtonTitle: "cancel").show()
            
            // no network
            print("no network connection")
            completionHandler(data: nil, error: networkReachabilityError)
            return
        }
        
        // we use AFHTTPRequestOperationManager for multipart form requests
        let manager = AFHTTPRequestOperationManager(baseURL: baseURL)
        
        // set basic authentication for request serializer
        manager.requestSerializer = AFJSONRequestSerializer()
        if isBasicAuthorization {
            manager.requestSerializer.setAuthorizationHeaderFieldWithUsername(Model.sharedModel.basicUserName, password: Model.sharedModel.basicPassword)
        }
        else {
            manager.requestSerializer.setValue(Model.sharedModel.bearerToken, forHTTPHeaderField: "Authorization")
        }
        
        if shouldShowHUD { SVProgressHUD.show() }
        
        // post as multipart data
        manager.POST(keyPath, parameters: params, constructingBodyWithBlock: nil, success:{ (operation, data) in
            
            SVProgressHUD.dismiss()
            
            // handle errors if any
            let dictionaryData = data as! NSDictionary
            if let metaData = dictionaryData["meta"] as? [String : AnyObject] {
                let meta = Meta(data: metaData)
                
                if meta.code != 200 {
                    // configure error
                    let error = NSError(domain: "", code: meta.code, userInfo: nil)
                    dispatch_async(dispatch_get_main_queue()) {
                        completionHandler(data: nil, error: error)
                    }
                    return
                }
            }
            else { print("XXX no meta found, fix api") }
            
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(data: data as? NSDictionary, error: nil)
            }
            }, failure: { (dataTask, error) in
                
                SVProgressHUD.dismiss()
                
                // customize the error here
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler (data: nil, error: error)
                }
        })
    }
    //
    //    func postMultiPartImage(url: String = "", fileName: String = "photo", params: [String: String] = [:], imageData: NSData, shouldShowHUD: Bool = false, completionHandler:(data: NSDictionary?, error: NSError?) -> ()) {
    //
    //        if !AFNetworkReachabilityManager.sharedManager().reachable {
    //
    //            UIAlertView(title: "alert_title_network_unreachable", message: "alert_message_network_unreachable", delegate: nil, cancelButtonTitle: "cancel").show()
    //
    //            // no network
    //            print("no network connection")
    //            completionHandler(data: nil, error: networkReachabilityError)
    //            return
    //        }
    //
    //        // we use AFHTTPRequestOperationManager for multipart form requests
    //        let manager = AFHTTPRequestOperationManager(baseURL: baseURL)
    //
    //        // set basic authentication for request serializer
    //        manager.requestSerializer = AFJSONRequestSerializer()
    //        manager.requestSerializer.setValue(Model.sharedModel.bearerToken, forHTTPHeaderField: "Authorization")
    //
    //        if shouldShowHUD { SVProgressHUD.show() }
    //
    //        manager.POST(url, parameters: params, constructingBodyWithBlock: { (formData: AFMultipartFormData!) -> Void in
    //
    //            formData.appendPartWithFileData(imageData, name: fileName, fileName: "photo.png", mimeType: "image/png")
    //            }, success:{ (operation, data) in
    //
    //                SVProgressHUD.dismiss()
    //
    //                print("response is \(data)")
    //
    //                // handle errors if any
    //                let dictionaryData = data as! NSDictionary
    //                if let metaData = dictionaryData["meta"] as? NSDictionary {
    //                    let meta = Meta(data: metaData)
    //
    //                    if meta.code != 200 {
    //                        // configure error
    //                        let error = NSError(domain: "", code: meta.code, userInfo: nil)
    //                        dispatch_async(dispatch_get_main_queue()) {
    //                            completionHandler(data: nil, error: error)
    //                        }
    //                        return
    //                    }
    //                }
    //                else { print("XXX no meta found, fix api") }
    //
    //                dispatch_async(dispatch_get_main_queue()) {
    //                    completionHandler(data: data as? NSDictionary, error: nil)
    //                }
    //            }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
    //
    //                SVProgressHUD.dismiss()
    //
    //                // customize the error here
    //                dispatch_async(dispatch_get_main_queue()) {
    //                    completionHandler (data: nil, error: error)
    //                }
    //        })
    //    }
    //
    //    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String) -> NSData {
    //        let body = NSMutableData();
    //
    //        if parameters != nil {
    //            for (key, value) in parameters! {
    //                body.appendString("--\(boundary)\r\n")
    //                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
    //                body.appendString("\(value)\r\n")
    //            }
    //        }
    //
    //        let filename = "user-profile.jpg"
    //
    //        let mimetype = "image/jpg"
    //
    //        body.appendString("--\(boundary)\r\n")
    //        body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
    //        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
    //        body.appendData(imageDataKey)
    //        body.appendString("\r\n")
    //
    //
    //
    //        body.appendString("--\(boundary)--\r\n")
    //
    //        return body
    //    }
    //
    //    func generateBoundaryString() -> String {
    //        return "Boundary-\(NSUUID().UUIDString)"
    //    }
    //
    
    func patchData(keyPath: String = "", params: [String: AnyObject] = [:], shouldShowHUD: Bool = false, completionHandler:(data: NSDictionary?, error: NSError?) -> ()) {
        
        if !AFNetworkReachabilityManager.sharedManager().reachable {
            
            UIAlertView(title: "alert_title_network_unreachable", message: "alert_message_network_unreachable", delegate: nil, cancelButtonTitle: "cancel").show()
            
            // no network
            print("no network connection")
            completionHandler(data: nil, error: networkReachabilityError)
            return
        }
        
        if shouldShowHUD { SVProgressHUD.show() }
        
        PATCH(keyPath, parameters: params, success: { (dataTask, data) in
            
            SVProgressHUD.dismiss()
            
            print("response is \(data)")
            
            // handle errors if any
            let dictionaryData = data as! NSDictionary
            if let metaData = dictionaryData["meta"] as? NSDictionary {
                let meta = Meta(data: metaData as! [String : AnyObject])
                
                if meta.code != 200 {
                    // configure error
                    let error = NSError(domain: "", code: meta.code, userInfo: nil)
                    dispatch_async(dispatch_get_main_queue()) {
                        completionHandler(data: nil, error: error)
                    }
                    return
                }
            }
            else { print("XXX no meta found, fix api") }
            
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(data: data as? NSDictionary, error: nil)
            }
            
            }, failure: { (dataTask, error) in
                
                SVProgressHUD.dismiss()
                
                // customize the error here
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler (data: nil, error: error)
                }
        })
    }
    
    //    func patchDataWithBasicAuthorizationToken(keyPath: String = "", var params: [String: AnyObject] = [:], shouldShowHUD: Bool = false, completionHandler:(data: NSDictionary?, error: NSError?) -> ()) {
    //
    //        if !AFNetworkReachabilityManager.sharedManager().reachable {
    //
    //            UIAlertView(title: "alert_title_network_unreachable", message: "alert_message_network_unreachable", delegate: nil, cancelButtonTitle: "cancel").show()
    //
    //            // no network
    //            print("no network connection")
    //            completionHandler(data: nil, error: networkReachabilityError)
    //            return
    //        }
    //
    //        if shouldShowHUD { SVProgressHUD.show() }
    //        let loginString = NSString(format: "%@:%@", Authentication.Basic.Username, Authentication.Basic.Password)
    //        let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
    //        let base64LoginString = loginData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
    //        params["access_token"] = base64LoginString
    //        print(base64LoginString)
    //        PATCH(keyPath, parameters: params, success: { (dataTask, data) in
    //
    //            SVProgressHUD.dismiss()
    //
    //            print("response is \(data)")
    //
    //            // handle errors if any
    //            let dictionaryData = data as! NSDictionary
    //            if let metaData = dictionaryData["meta"] as? NSDictionary {
    //                let meta = Meta(data: metaData)
    //
    //                if meta.code != 200 {
    //                    // configure error
    //                    let error = NSError(domain: "", code: meta.code, userInfo: nil)
    //                    dispatch_async(dispatch_get_main_queue()) {
    //                        completionHandler(data: nil, error: error)
    //                    }
    //                    return
    //                }
    //            }
    //            else { print("XXX no meta found, fix api") }
    //
    //            dispatch_async(dispatch_get_main_queue()) {
    //                completionHandler(data: data as? NSDictionary, error: nil)
    //            }
    //
    //            }, failure: { (dataTask, error) in
    //
    //                SVProgressHUD.dismiss()
    //
    //                // customize the error here
    //                dispatch_async(dispatch_get_main_queue()) {
    //                    print("XXX no meta found, fix api",error)
    //                    completionHandler (data: nil, error: error)
    //                }
    //        })
    //    }
}
