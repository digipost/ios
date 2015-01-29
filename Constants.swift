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
    
    struct Error {
        static let apiErrorDomainOAuthUnauthorized = "oAuthUnauthorized"
        
        static let apiClientErrorDomain = "APIManagerErrorDomain"
        
        enum Code : Int {
            case oAuthUnathorized = 4001
            case uploadFileDoesNotExist = 4002
            case uploadFileTooBig = 4003
            case uploadLinkNotFoundInRootResource = 4004
            case uploadFailed = 4005
            case NeedHigherAuthenticationLevel = 4006
        }
    }
}

func == (left:Int, right:Constants.Error.Code) -> Bool {
    return left == right.rawValue
}

func == (left:Constants.Error.Code, right:Int) -> Bool {
    return left.rawValue == right
}

