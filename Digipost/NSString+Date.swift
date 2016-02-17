//
//  String+Date.swift
//  Digipost
//
//  Created by Fredrik Lillejordet on 17/02/16.
//  Copyright © 2016 Posten. All rights reserved.
//

import Foundation

extension NSString {
    func validDateFormat() -> NSString? {
        if let r: NSRange = self.rangeOfString(".", options: NSStringCompareOptions.BackwardsSearch){
            if r.length > 0 {
                return self.substringToIndex(r.location)
            }
        }
        return self;
    }
}