//
//  BaseUrlViewController.swift
//  ApiChecker
//
//  Created by Thahir Maheen on 31/03/16.
//  Copyright © 2016 FAYA. All rights reserved.
//

import UIKit

class BaseUrlViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var textFieldBaseUrl: UITextField!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        textFieldBaseUrl?.text = Model.sharedModel.baseURL
        
        textFieldBaseUrl.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        // update model
        Model.sharedModel.baseURL = textFieldBaseUrl.text ?? ""
        
        performSegueWithIdentifier(Storyboard.Segues.AuthorizationSegue, sender: self)
    }
    
    struct Storyboard {
        struct Segues {
            static let AuthorizationSegue = "kAuthorizationSegue"
        }
    }
}
