//
//  AuthorizationViewController.swift
//  ApiChecker
//
//  Created by Thahir Maheen on 31/03/16.
//  Copyright © 2016 FAYA. All rights reserved.
//

import UIKit

class AuthorizationViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var textFieldBasicUsername: UITextField!
    @IBOutlet weak var textFieldBasicPassword: UITextField!
    
    @IBOutlet weak var textFieldBearerToken: UITextField!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        configureView()
    }
    
    func configureView() {
        textFieldBasicUsername.text = Model.sharedModel.basicUserName
        textFieldBasicPassword.text = Model.sharedModel.basicPassword
        textFieldBearerToken.text = Model.sharedModel.bearerToken
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    struct Storyboard {
        struct Segues {
            static let MethodSegue = "kMethodSegue"
        }
    }
    
    @IBAction func buttonActionBasicAuthorization(sender: UIButton) {
        // update model
        Model.sharedModel.basicUserName = textFieldBasicUsername.text!
        Model.sharedModel.basicPassword = textFieldBasicPassword.text!
    
        // authorize
        Model.sharedModel.parseEngine.setBasicAuthorization()
        
        performSegueWithIdentifier(Storyboard.Segues.MethodSegue, sender: self)
    }
    
    @IBAction func buttonActionBearerAuthorization(sender: UIButton) {
        // update model
        Model.sharedModel.bearerToken = textFieldBearerToken.text!
        
        // authorize
        Model.sharedModel.parseEngine.setBearerAuthorization()
        
        performSegueWithIdentifier(Storyboard.Segues.MethodSegue, sender: self)
    }
}
