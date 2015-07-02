//
//  NSURLResponse+HTTP.swift
//  Digipost
//
//  Created by Håkon Bogen on 23/03/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

extension NSHTTPURLResponse {
    
    func didSuceed() -> Bool {
        if 200...299 ~= statusCode {
            return true
        }
        return false
    }

    func didFail() -> Bool {
        if  300...599 ~= statusCode {
            return true
        }
        return false
    }
}
