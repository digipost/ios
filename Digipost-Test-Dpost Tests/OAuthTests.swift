//
//  OAuthTests.swift
//  Digipost
//
//  Created by Håkon Bogen on 26/11/14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

import UIKit
import XCTest

class OAuthTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        LUKeychainAccess.standardKeychainAccess().deleteAll()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func jsonDictionaryFromFile(filename: String) -> Dictionary<String, AnyObject> {
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
    
    func mockTokenWithScope(scope: String) -> OAuthToken {
        let oAuthDictionary = jsonDictionaryFromFile("ValidOAuthToken.json")
        let token = OAuthToken(attributes: oAuthDictionary, scope: scope)
        return token!
    }

    func testOauthFromDictionary() {
        
        let oAuthDictionary = jsonDictionaryFromFile("ValidOAuthToken.json")
        let token = OAuthToken(attributes: oAuthDictionary, scope: "scope")
        XCTAssertNotNil(token, "no valid token was created")
        
        let invalidAuthDictionary = jsonDictionaryFromFile("InvalidOAuthToken.json")
        let anotherToken = OAuthToken(attributes: invalidAuthDictionary, scope: "anotherScope")
        XCTAssertNil(anotherToken, "token should not have been created")
 
    }
    
    func testMultipleScopedTokensInKeychain() {
        let fullToken = mockTokenWithScope(kOauth2ScopeFull)
        // create an invalid token that does not get stored
        let invalidAuthDictionary = jsonDictionaryFromFile("InvalidOAuthToken.json")
        let anotherToken = OAuthToken(attributes: invalidAuthDictionary, scope: "anotherScope")
        let allTokens = OAuthToken.oAuthTokens()
        XCTAssertTrue(allTokens.count == 1, "token did not correctly store in database")
    }
    
    func testUpdateSameTokenMultipleTimes () {
        let newAccessToken = "newAccessToken"
        let fullToken = mockTokenWithScope(kOauth2ScopeFull)
        
        let refetchedToken = OAuthToken.oAuthTokenWithScope(kOauth2ScopeFull)
        XCTAssertNotNil(refetchedToken, "no valid token was created")
        println(refetchedToken)
        
        refetchedToken!.accessToken = newAccessToken
        
        let alteredToken = OAuthToken.oAuthTokenWithScope(kOauth2ScopeFull)
        let acc = alteredToken?.accessToken!
        XCTAssertTrue(alteredToken!.accessToken! == refetchedToken!.accessToken!, "\(alteredToken!.accessToken!) not similar to \(refetchedToken!.accessToken!)")
        
    }

}
