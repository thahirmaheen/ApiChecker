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

    var baseURL = ""
    
    var basicUserName = ""
    var basicPassword = ""
    
    var bearerToken = ""
}