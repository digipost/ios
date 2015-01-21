//
//  APIError.swift
//  Digipost
//
//  Created by Håkon Bogen on 20/01/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

class APIError: NSError {
    
    init(error: NSError) {
        super.init(domain: error.domain, code: error.code, userInfo: error.userInfo)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

//    required init(coder aDecoder: NSCoder) {
//    }
    
    var alertTitle : String {
        switch self.code {
        default:
            return ""
        }
    }
    
    var altertText : String {
        switch self.code {
        default:
            return ""
        }
    }
    
    var shouldBeShownToUser : Bool = true
    
}
