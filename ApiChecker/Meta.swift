//
//  Meta.swift
//  ApiChecker
//
//  Created by Thahir Maheen on 31/03/16.
//  Copyright © 2016 FAYA. All rights reserved.
//

import Foundation

class Meta {
    
    var status = ""
    var code = 200
    var message = ""
    
    init(data: [String: AnyObject]) {
        self.status = data[Api.Keys.Status] as? String ?? ""
        self.code = data[Api.Keys.Code] as? Int ?? 200
        self.message = data[Api.Keys.Message] as? String ?? ""
    }
    
    struct Api {
        struct Keys {
            static let Status = "status"
            static let Code = "code"
            static let Message = "message"
        }
    }
}