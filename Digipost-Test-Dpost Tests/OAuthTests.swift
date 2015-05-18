//
//  OAuthTests.swift
//  Digipost
//
//  Created by Håkon Bogen on 26/11/14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

import UIKit
import XCTest
import LUKeychainAccess

class OAuthTests: XCTestCase, LUKeychainErrorHandler {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        super.tearDown()
        OAuthToken.removeAllTokens()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func jsonDictionaryFromFile(filename: String) -> Dictionary<String, AnyObject> {
        let testBundle = NSBundle(forClass: OAuthTests.self)
        let path = testBundle.pathForResource(filename, ofType: nil)
        XCTAssertNotNil(path, "wrong filename")
        let data = NSData(contentsOfFile: path!)
        XCTAssertNotNil(data, "wrong filename")
        var error : NSError?
        let jsonDictionary = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: &error) as! Dictionary<String,AnyObject>
        XCTAssertNil(error, "could not read json")
        return jsonDictionary
    }

    func mockTokenWithScope(scope: String) -> OAuthToken {
        var oAuthDictionary: Dictionary<String,AnyObject>!
        if scope == kOauth2ScopeFull {
            oAuthDictionary = jsonDictionaryFromFile("ValidOAuthToken.json")
        } else {
            oAuthDictionary = jsonDictionaryFromFile("ValidOAuthTokenHigherSecurity.json")
        }
        let token = OAuthToken(attributes: oAuthDictionary, scope: scope)
        return token!
    }

    func testOauthFromDictionary() {
        let oAuthDictionary = jsonDictionaryFromFile("ValidOAuthToken.json")
        let token = OAuthToken(attributes: oAuthDictionary, scope: kOauth2ScopeFull)
        XCTAssertNotNil(token, "no valid token was created")
        
    }
    
    func testOauthFromStrings() {
        LUKeychainAccess.standardKeychainAccess().errorHandler = self
        let accesstoken = "accesstoken"
        let fierje = OAuthToken.oAuthTokenWithScope(kOauth2ScopeFull)

        let token = OAuthToken(refreshToken: "refreifasfkalerjwerw", accessToken: accesstoken, scope: kOauth2ScopeFull, expiresInSeconds: 15)
        let fetchedToken = OAuthToken.oAuthTokenWithScope(kOauth2ScopeFull)
        XCTAssertNotNil(fetchedToken, "could not store oauthtoken to keychain")
        XCTAssertEqual(fetchedToken!.accessToken!, accesstoken, "wrong accesstoken stored")

    }

    func keychainAccess(keychainAccess: LUKeychainAccess!, receivedError error: NSError!) {
        println(error)
        XCTAssertTrue(false, "got an error message \(error) from keychain")
    }

    func testMultipleScopedTokensInKeychain() {
        let fullToken = mockTokenWithScope(kOauth2ScopeFull)
        // create an invalid token that does not get stored
        let invalidAuthDictionary = jsonDictionaryFromFile("ValidOAuthToken.json")
        let anotherToken = OAuthToken(attributes: invalidAuthDictionary, scope: kOauth2ScopeFullHighAuth)
        let allTokens = OAuthToken.oAuthTokens()
        XCTAssertTrue(allTokens.count == 2, "token did not correctly store in database")
    }

    // creates a token, fetches it from keychain, adds a new access token, then refetches to see if it did get updated
    func testUpdateSameTokenMultipleTimes () {
        let newAccessToken = "newAccessToken"
        let fullToken = mockTokenWithScope(kOauth2ScopeFull)
        
        let refetchedToken = OAuthToken.oAuthTokenWithScope(kOauth2ScopeFull)
        XCTAssertNotNil(refetchedToken, "no valid token was created")
        
        refetchedToken!.accessToken = newAccessToken
        
        let alteredToken = OAuthToken.oAuthTokenWithScope(kOauth2ScopeFull)
        let acc = alteredToken?.accessToken!
        XCTAssertTrue(alteredToken!.accessToken! == refetchedToken!.accessToken!, "\(alteredToken!.accessToken!) not similar to \(refetchedToken!.accessToken!)")
    }

    func testMultipleScopes() {
        let fullToken = mockTokenWithScope(kOauth2ScopeFull)
        let fullHighAuth = mockTokenWithScope(kOauth2ScopeFullHighAuth)
        let idPorten3 = mockTokenWithScope(kOauth2ScopeFull_Idporten3)
        let idPorten4 = mockTokenWithScope(kOauth2ScopeFull_Idporten4)
        let allTokens = OAuthToken.oAuthTokens()
        XCTAssertNil(idPorten3.refreshToken, "idporten3 token should not have refresh token")
        XCTAssertTrue(allTokens.count == 4, "token did not correctly store in database, should be 4, was \(allTokens.count)")
    }

    func testdeleteAllTokens () {
        let fullToken = mockTokenWithScope(kOauth2ScopeFull)
        let fullHighAuth = mockTokenWithScope(kOauth2ScopeFullHighAuth)
        let idPorten3 = mockTokenWithScope(kOauth2ScopeFull_Idporten3)
        let idPorten4 = mockTokenWithScope(kOauth2ScopeFull_Idporten4)
        let allTokens = OAuthToken.oAuthTokens()
        XCTAssertTrue(allTokens.count == 4, "token did not correctly store in database, should be 4, was \(allTokens.count)")
        
        OAuthToken.removeAllTokens()
        let allTokensAfterDeletion = OAuthToken.oAuthTokens()
        XCTAssertTrue(allTokensAfterDeletion.count == 0, "could not delete token database, should be 0, was \(allTokensAfterDeletion.count)")
    }

    func testTimeOutToken() {
        let expectation = expectationWithDescription("Waiting for timeout on oauthToken")
        let timeout : NSTimeInterval = 10
        let fullToken = OAuthToken(refreshToken: "refreshtoken", accessToken: "accessToken", scope: kOauth2ScopeFull, expiresInSeconds: timeout)
        XCTAssertFalse(fullToken!.hasExpired(), "token expired before its time! time is \(NSDate()) and it expired \(fullToken?.expires)")

        dispatch(after: timeout + 3) {
            let fetchedToken = OAuthToken.oAuthTokenWithScope(kOauth2ScopeFull)
            XCTAssertTrue(fetchedToken!.hasExpired(), "token should have expired! Time is \(NSDate()) and it expired \(fullToken?.expires)")
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(timeout + 5, handler: { (error) -> Void in
            XCTAssertNil(error, "\(error)")
        })
    }

    func testRenewAccessTokensForMultipleOauthTokens(){
        let newAccessTokenFull = "new Acesstoken for Full"
        let newAccessTokenHighAuth = "new Acesstoken for HighAuth"
        let newAccessTokenIdPorten4 = "new Acesstoken for idporten4"
        let fullToken = mockTokenWithScope(kOauth2ScopeFull)
        let fullHighAuth = mockTokenWithScope(kOauth2ScopeFullHighAuth)
        let idPorten3 = mockTokenWithScope(kOauth2ScopeFull_Idporten3)
        let idPorten4 = mockTokenWithScope(kOauth2ScopeFull_Idporten4)

        let fetchedFull = OAuthToken.oAuthTokenWithScope(kOauth2ScopeFull)
        let fetchedHighAuth = OAuthToken.oAuthTokenWithScope(kOauth2ScopeFullHighAuth)
        let fetchedIdPorten4 = OAuthToken.oAuthTokenWithScope(kOauth2ScopeFull_Idporten4)
        
        fetchedFull?.accessToken = newAccessTokenFull
        fetchedHighAuth?.accessToken = newAccessTokenHighAuth
        fetchedIdPorten4?.accessToken = newAccessTokenIdPorten4
        
        let refetchedFull = OAuthToken.oAuthTokenWithScope(kOauth2ScopeFull)
        XCTAssertEqual(refetchedFull!.accessToken!, newAccessTokenFull, "did not save new access token correctly")
        let refetchedHighAuth = OAuthToken.oAuthTokenWithScope(kOauth2ScopeFullHighAuth)
        XCTAssertEqual(refetchedHighAuth!.accessToken!, newAccessTokenHighAuth, "did not save new access token correctly")
        
        let refetchedIdporten4 = OAuthToken.oAuthTokenWithScope(kOauth2ScopeFull_Idporten4)
        XCTAssertEqual(refetchedIdporten4!.accessToken!, newAccessTokenIdPorten4, "did not save new access token correctly")
    }
}
