//
//  String+Extensions.swift
//  Digipost
//
//  Created by Hannes Waller on 2015-01-15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import Foundation

extension String {

    func getInitials() -> String {
        
        var arr = split(self) { $0 == " " }
        
        if arr.count == 0 { return "" }
        
        return  arr[0].getFirstLetter() + arr[arr.count - 1].getFirstLetter()
    }
    
    func getFirstLetter() -> String {
        for c in self {
            return "\(c)"
        }
        
        return ""
    }
    
}
