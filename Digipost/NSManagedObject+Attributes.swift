//
//  NSManagedObject+Attributes.swift
//  Digipost
//
//  Created by Håkon Bogen on 21/10/14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

import UIKit

extension NSManagedObject {
    // json dict of attributes
    func dictionaryOfAttributes() -> NSDictionary {
        
        let attributes = NSMutableDictionary()
        for var index=0; index < reflect(self).count; ++index {
            
            let key = reflect(self)[index].0
            
            // ignore the super reference key and value
            if key == "super" {
                continue
            }
            
            let value = reflect(self)[index].1.summary
            
            attributes[key] = value
            
        }
        return attributes
    }
}
