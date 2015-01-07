//
//  APIResponse.swift
//  Digipost
//
//  Created by Håkon Bogen on 06/01/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import Foundation

class APIResponse: NSObject {
    var json: AnyObject?
    var date: NSDate?
    
    init(json: AnyObject?, date: NSDate?) {
        self.json = json
        self.date = date
    }
}