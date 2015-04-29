//
//  RAC-Helper.swift
//  Digipost
//
//  Created by Håkon Bogen on 05/01/15.
//  Copyright (c) 2015 Håkon Bogen. All rights reserved.
//

import Foundation

struct RAC {
    var target : NSObject!
    var keyPath : String!
    var nilValue : AnyObject!
    
    init(_ target: NSObject!, _ keyPath: String, nilValue: AnyObject? = nil) {
        self.target = target
        self.keyPath = keyPath
        self.nilValue = nilValue
    }
}
