//
//  Constants.swift
//  Digipost
//
//  Created by Håkon Bogen on 05/01/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import Foundation

struct Constants {
    
    struct APIClient {
        static let taskCounter = "taskCounter"
        static var baseURL : String {
            return __SERVER_URI__
        }
    }
    
    struct HTTPHeaderKeys {
        static let accept = "Accept"
        static let contentType = "Content-Type"
    }
}