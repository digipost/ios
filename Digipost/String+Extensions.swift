//
//  String+Extensions.swift
//  Digipost
//
//  Created by Hannes Waller on 2015-01-15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import Foundation

extension String {

    func initials() -> String {
        
        var arr = split(self) { $0 == " " }
        
        if arr.count == 0 { return "" }
        
        return  arr[0].firstLetter() + arr[arr.count - 1].firstLetter()
    }
    
    func firstLetter() -> String {
        for c in self {
            return "\(c)"
        }
        
        return ""
    }
    
}

extension NSString {
    
    func initials() -> NSString {
        var arr = self.componentsSeparatedByString(" ")
        if arr.count == 0 { return "" }
        
        return  (arr[0].firstLetter() as String) + (arr[arr.count - 1].firstLetter() as String)
    }
    
    func firstLetter() -> NSString {
        return self.substringToIndex(1)
    }
    
}
