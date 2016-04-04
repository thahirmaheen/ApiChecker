//
//  MethodsViewController.swift
//  ApiChecker
//
//  Created by Thahir Maheen on 01/04/16.
//  Copyright © 2016 FAYA. All rights reserved.
//

import UIKit

class MethodsViewController: UITableViewController {
    
    struct Storyboard {
        struct Segues {
            static let GetSegue = "kGetSegue"
            static let PostSegue = "kPostSegue"
            static let PatchSegue = "kPatchSegue"
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let inputsViewController = segue.destinationViewController as! InputsViewController
        switch segue.identifier! {
        case Storyboard.Segues.GetSegue: inputsViewController.method = .GET
        case Storyboard.Segues.PostSegue: inputsViewController.method = .POST
        case Storyboard.Segues.PatchSegue: inputsViewController.method = .PATCH
        default: inputsViewController.method = .GET
        }
    }
}
