//
//  XCTestCase+Convenience.swift
//  Digipost
//
//  Created by Håkon Bogen on 20/01/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit
import XCTest

extension XCTestCase {
    
    class func jsonDictionaryFromFile(filename: String) -> Dictionary<String, AnyObject> {
        let testBundle = NSBundle(forClass: OAuthTests.self)
        let path = testBundle.pathForResource(filename, ofType: nil)
        XCTAssertNotNil(path, "wrong filename")
        let data = NSData(contentsOfFile: path!)
        XCTAssertNotNil(data, "wrong filename")
        var error : NSError?
        let jsonDictionary = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: &error) as Dictionary<String,AnyObject>
        XCTAssertNil(error, "could not read json")
        return jsonDictionary
    }
    
    class func mockTokenWithScope(scope: String) -> OAuthToken {
        var oAuthDictionary: Dictionary <String,AnyObject>!
        if scope == kOauth2ScopeFull {
            oAuthDictionary =  XCTestCase.jsonDictionaryFromFile("ValidOAuthToken.json")
        } else {
            oAuthDictionary = XCTestCase.jsonDictionaryFromFile("ValidOAuthTokenHigherSecurity.json")
        }
        let token = OAuthToken(attributes: oAuthDictionary, scope: scope)
        return token!
    }
}
