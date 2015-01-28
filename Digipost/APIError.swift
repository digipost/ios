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
    
//    init(domain: String, code: Int, userInfo dict: [NSObject : AnyObject]?)
    
    override init(domain: String, code: Int, userInfo dict: [NSObject : AnyObject]?) {
        super.init(domain: domain, code: code, userInfo: dict)
    }
    

    class func UnauthorizedOAuthTokenError() -> APIError {
        let apierror = APIError(domain: Constants.Error.apiErrorDomainOAuthUnauthorized, code: Constants.Error.Code.oAuthUnathorized.rawValue, userInfo: nil)
        return apierror
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
