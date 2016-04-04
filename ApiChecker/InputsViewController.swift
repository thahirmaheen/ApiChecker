//
//  InputsViewController.swift
//  ApiChecker
//
//  Created by Thahir Maheen on 01/04/16.
//  Copyright © 2016 FAYA. All rights reserved.
//

import UIKit

enum Method {
    case GET, POST, PATCH
}

class Parameter {
    var key = ""
    var value = ""
}

protocol KeyPathCellDelegate {
    func keyPathCell(keyPathCell: KeyPathCell, didSetKeyPath keyPath: String)
}

class KeyPathCell: UITableViewCell, UITextFieldDelegate {
    
    var keyPathCellDelegate: KeyPathCellDelegate?
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        keyPathCellDelegate?.keyPathCell(self, didSetKeyPath: textField.text!)
    }
}

protocol ParameterCellDelegate {
    func parameterCell(parameterCell: ParameterCell, didSetParameter parameter: Parameter)
}

class ParameterCell: UITableViewCell {
    
    var parameter = Parameter()
    var parameterCellDelegate: ParameterCellDelegate?
    
}

class InputsViewController: UITableViewController, KeyPathCellDelegate, ParameterCellDelegate {
    
    var method = Method.GET
    var keyPath = ""
    var params = [Parameter]()

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : (params.count + 1)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // keypath cell
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellIdentifiers.KeyPathCell, forIndexPath: indexPath) as! KeyPathCell
            cell.keyPathCellDelegate = self
            return cell
        }
        
        // parameter cell
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellIdentifiers.ParameterCell, forIndexPath: indexPath) as! ParameterCell
        cell.parameterCellDelegate = self
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ["Key Path", "Parameters"][section]
    }
    
    func keyPathCell(keyPathCell: KeyPathCell, didSetKeyPath keyPath: String) {
        self.keyPath = keyPath
    }
    
    func parameterCell(parameterCell: ParameterCell, didSetParameter parameter: Parameter) {
        
    }

    struct Storyboard {
        struct Segues {
            static let ProcessSegue = "kProcessSegue"
        }
        
        struct CellIdentifiers {
            static let KeyPathCell = "kKeyPathCell"
            static let ParameterCell = "kParameterCell"
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Storyboard.Segues.ProcessSegue {
            let outputViewController = segue.destinationViewController as! OutputViewController
            outputViewController.output = sender as! String
        }
    }

    @IBAction func buttonActionProcess(sender: UIBarButtonItem) {
        
        Model.sharedModel.processAPI(method, keyPath: keyPath, params: [:]) { output in
            self.performSegueWithIdentifier(Storyboard.Segues.ProcessSegue, sender: output)
        }
    }
}
