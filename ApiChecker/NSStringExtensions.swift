//
//  NSString.swift
//  FlexYourMacros
//
//  Created by Thahir Maheen on 27/03/15.
//  Copyright (c) 2015 Digital Brand Group. All rights reserved.
//

import Foundation

// MARK: Localization
prefix operator && {}

prefix func && (string: String) -> String {
    return NSLocalizedString(string, comment: "")
}

// MARK: Filtering
extension String {
    
    func filterWordsWithPrefix(prefix: String, shouldStripPrefix: Bool) -> [String] {
    
        // the regular expression to filter out words
        let regularExpression = try! NSRegularExpression(pattern: "\(prefix)(\\w+)", options: .CaseInsensitive)
        
        // filter out results using the regular expression
        let arrayMatches = regularExpression.matchesInString(self, options: .WithTransparentBounds, range: NSMakeRange(0, self.characters.count))
        
        // return words from results
        return arrayMatches.map() {
            (self as NSString).substringWithRange($0.rangeAtIndex(shouldStripPrefix ? 1 : 0))
        }
    }
    
    func filterHashTags() -> [String] {
        return filterWordsWithPrefix("#", shouldStripPrefix: false)
    }
    
    func contains(find: String) -> Bool{
        return self.rangeOfString(find, options: NSStringCompareOptions.CaseInsensitiveSearch) != nil
    }
}

// MARK: Date
extension String {
    
    // dateFormat has precedence over dateStyle
    // date style defaults to LongStyle
    func dateValue(dateFormat: String? = nil, dateStyle: NSDateFormatterStyle? = nil) -> NSDate? {
        
        // get a date formatter
        let dateFormatter = NSDateFormatter()
        
        // set appropriate date styles/formats
        if let dateFormat = dateFormat {
            dateFormatter.dateFormat = dateFormat
        }
        else if let dateStyle = dateStyle {
            dateFormatter.dateStyle = dateStyle
        }
        else {
            dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        }
        
        // return the date after formatting
        return dateFormatter.dateFromString(self)
    }
    
    func utcDateValue(dateFormat: String? = nil, dateStyle: NSDateFormatterStyle? = nil) -> NSDate? {
        
        // get a date formatter
        let dateFormatter = NSDateFormatter()
        
        // set appropriate date styles/formats
        if let dateFormat = dateFormat {
            dateFormatter.dateFormat = dateFormat
        }
        else if let dateStyle = dateStyle {
            dateFormatter.dateStyle = dateStyle
        }
        else {
            dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        }
        
        // set gmt 0
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        
        // return the date after formatting
        return dateFormatter.dateFromString(self)
    }
}

// MARK: Conversion
extension String {
    
    var intValue: Int {
        return (self as NSString).integerValue
    }
    
    var floatValue: Float {
        return (self as NSString).floatValue
    }
    
    var doubleValue: Double {
        return (self as NSString).doubleValue
    }
    
}

// MARK: Validation
extension String {
    
    var isNonEmpty: Bool {
        return !self.removeWhitespace().removeNewLine().isEmpty
    }
    
    var isValidPassword: Bool {
        return self.characters.count >= 6
    }
    
    var isValidEmailAddress: Bool {
        let regex = try? NSRegularExpression(pattern: "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$", options: .CaseInsensitive)
        return regex?.firstMatchInString(self, options: [], range: NSMakeRange(0, self.characters.count)) != nil
    }
    
    var isNumeric: Bool {
        return Int(self) != nil
    }
        
    func isRespectingCharacterLimit(limit: Int = 4) -> Bool {
        return characters.count <= limit
    }
}

extension String {
    func replace(string:String, replacement:String) -> String {
        return self.stringByReplacingOccurrencesOfString(string, withString: replacement, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    func removeWhitespace() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    func removeNewLine() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
    }
}