//
//  InputsViewController.swift
//  ApiChecker
//
//  Created by Thahir Maheen on 01/04/16.
//  Copyright © 2016 FAYA. All rights reserved.
//

import UIKit

enum Method {
    case GET, POST, PATCH, MULTIPARTPOST
}

class Parameter: Hashable, Equatable {
    var key = ""
    var value = ""
    
    var hashValue: Int {
        return key.hashValue
    }
    
    var isValid: Bool {
        return key.isNonEmpty && value.isNonEmpty
    }
    
    var isDeletable: Bool {
        return key.isNonEmpty || value.isNonEmpty
    }
    
    var description: String {
        return key + ": " + value
    }
}

func ==(lhs: Parameter, rhs: Parameter) -> Bool {
    return lhs.key == rhs.key
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

class ParameterCell: UITableViewCell, UITextFieldDelegate {
    
    var parameter = Parameter() {
        didSet {
            configureView()
        }
    }
    
    var parameterCellDelegate: ParameterCellDelegate?
    
    @IBOutlet weak var textFieldKey: UITextField!
    @IBOutlet weak var textFieldValue: UITextField!
    
    func configureView () {
        textFieldKey?.text = parameter.key
        textFieldValue?.text = parameter.value
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        if let text = textField.text {
            if textField == textFieldKey {
                parameter.key = text
            }
            else {
                parameter.value = text
            }
        }
        
        parameterCellDelegate?.parameterCell(self, didSetParameter: parameter)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        parameter = Parameter()
    }
}

class InputsViewController: UITableViewController, KeyPathCellDelegate, ParameterCellDelegate {
    
    var method = Method.GET
    var keyPath = ""
    var parameters = Set<Parameter>()
    
    var arrayParameterCells = [ParameterCell]()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        buildCells()
    }
    
    func buildCells() {
        
        // clear cells
        arrayParameterCells = []
        
        // build cells for each parameter
        for parameter in parameters {
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellIdentifiers.ParameterCell) as! ParameterCell
            cell.parameter = parameter
            cell.parameterCellDelegate = self
            
            arrayParameterCells.append(cell)
        }
        
        // add an empty cell to add parameter
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellIdentifiers.ParameterCell) as! ParameterCell
        cell.parameterCellDelegate = self
        
        arrayParameterCells.append(cell)
        
        // reload tableview
        tableView.reloadData()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : arrayParameterCells.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // keypath cell
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellIdentifiers.KeyPathCell, forIndexPath: indexPath) as! KeyPathCell
            cell.keyPathCellDelegate = self
            return cell
        }
        return arrayParameterCells[indexPath.row]
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ["Key Path", "Parameters"][section]
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return ((tableView.cellForRowAtIndexPath(indexPath) as? ParameterCell)?.parameter.isDeletable ?? false) && (arrayParameterCells.count > 1)
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            // remove row
            tableView.beginUpdates()
            let cell = arrayParameterCells[indexPath.row]
            parameters.remove(cell.parameter)
            arrayParameterCells.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)            
            tableView.endUpdates()
        }
    }
    
    func keyPathCell(keyPathCell: KeyPathCell, didSetKeyPath keyPath: String) {
        self.keyPath = keyPath
    }
    
    func parameterCell(parameterCell: ParameterCell, didSetParameter parameter: Parameter) {
        if parameter.isValid {
            parameters.insert(parameter)
            
            // XXX reloading whole table to handle edit cases
            buildCells()
        }
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
        
        // stop editing
        view.endEditing(true)
        
        var dictParams = [String: String]()
        for parameter in parameters.filter({ $0.isValid }) {
            dictParams[parameter.key] = parameter.value
        }
        
        Model.sharedModel.processAPI(method, keyPath: keyPath, params: dictParams) { output in
            self.performSegueWithIdentifier(Storyboard.Segues.ProcessSegue, sender: output)
        }
    }
}
