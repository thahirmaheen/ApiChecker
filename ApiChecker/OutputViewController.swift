//
//  OutputViewController.swift
//  ApiChecker
//
//  Created by Thahir Maheen on 01/04/16.
//  Copyright © 2016 FAYA. All rights reserved.
//

import UIKit

class OutputViewController: UIViewController {
    
    var output = ""

    @IBOutlet weak var textView: UITextView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        textView.text = output
    }
}
