//
//  String+URL.swift
//  Digipost
//
//  Created by Fredrik Lillejordet on 11/01/16.
//  Copyright © 2016 Posten. All rights reserved.
//

import Foundation
extension String {
    
    func urlRepresentation() -> NSURL{
        return NSURL(fileURLWithPath: self)
    }

}