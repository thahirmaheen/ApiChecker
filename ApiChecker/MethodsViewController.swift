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
            static let MultipartPostSegue = "kMultipartPostSegue"
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let inputsViewController = segue.destinationViewController as! InputsViewController
        switch segue.identifier! {
        case Storyboard.Segues.GetSegue: inputsViewController.method = .GET
        case Storyboard.Segues.PostSegue: inputsViewController.method = .POST
        case Storyboard.Segues.PatchSegue: inputsViewController.method = .PATCH
        case Storyboard.Segues.MultipartPostSegue: inputsViewController.method = .MULTIPARTPOST
        default: inputsViewController.method = .GET
        }
    }
}
