//
//  NSURLResponse+Authorization.swift
//  Digipost
//
//  Created by Håkon Bogen on 10/06/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

extension NSHTTPURLResponse {
    

    class func isUnathorized(response: NSHTTPURLResponse?) -> Bool {
        if response == nil {
            return false
        }
        switch response!.statusCode {
        case 401:
            return true
        default:
            break
        }

        return false
        
    }
}
