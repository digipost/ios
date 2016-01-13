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
        OAuthToken.removeAllTokens()
    }
    
    override func tearDown() {
        super.tearDown()
        OAuthToken.removeAllTokens()
    }
    
    func jsonDictionaryFromFile(filename: String) -> Dictionary<String, AnyObject> {
        let testBundle = NSBundle(forClass: OAuthTests.self)
        let path = testBundle.pathForResource(filename, ofType: nil)
        XCTAssertNotNil(path, "wrong filename")
        let data = NSData(contentsOfFile: path!)
        XCTAssertNotNil(data, "wrong filename")
        do{
            let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! Dictionary<String,AnyObject>
            return jsonDictionary
        }catch let error{
            XCTAssertNil(error, "could not read json")
            return Dictionary<String, AnyObject>()
        }
        
    }

    var mockNonce = "-880201503"

    func mockTokenWithScope(scope: String) -> OAuthToken {

        var oAuthDictionary: Dictionary<String,AnyObject>!
        if scope == kOauth2ScopeFull {
            oAuthDictionary = jsonDictionaryFromFile("ValidOAuthToken.json")
        } else {
            oAuthDictionary = jsonDictionaryFromFile("ValidOAuthTokenHigherSecurity.json")
        }
        let token = OAuthToken(attributes: oAuthDictionary, scope: scope, nonce: mockNonce)
        return token!

    }

    func testCreateTokenFromJsonDictionary() {
        let oAuthDictionary = jsonDictionaryFromFile("ValidOAuthToken.json")
        let token = OAuthToken(attributes: oAuthDictionary, scope: kOauth2ScopeFull, nonce: mockNonce)
        XCTAssertNotNil(token, "no valid token was created")
    }

    // just in case there is a general error with keychain
    func keychainAccess(keychainAccess: LUKeychainAccess!, receivedError error: NSError!) {
        XCTAssertTrue(false, "got an error message \(error) from keychain")
    }

    func testKeepTokensWithDifferentScopesInKeychain() {
        let fullToken = mockTokenWithScope(kOauth2ScopeFull)
        // create an invalid token that does not get stored
        let invalidAuthDictionary = jsonDictionaryFromFile("ValidOAuthToken.json")
        let anotherToken = OAuthToken(attributes: invalidAuthDictionary, scope: kOauth2ScopeFullHighAuth, nonce: mockNonce)
        let allTokens = OAuthToken.oAuthTokens()
        XCTAssertTrue(allTokens.count == 2, "token did not correctly store in database")
    }

    // creates a token, fetches it from keychain, adds a new access token, then refetches to see if it did get updated
    func testUpdateSameTokenMultipleTimes() {
        let newAccessToken = "newAccessToken"
        let fullToken = mockTokenWithScope(kOauth2ScopeFull)
        
        let refetchedToken = OAuthToken.oAuthTokenWithScope(kOauth2ScopeFull)
        XCTAssertNotNil(refetchedToken, "no valid token was created")
        
        refetchedToken!.accessToken = newAccessToken
        
        let alteredToken = OAuthToken.oAuthTokenWithScope(kOauth2ScopeFull)
        let acc = alteredToken?.accessToken!
        XCTAssertTrue(alteredToken!.accessToken! == refetchedToken!.accessToken!, "\(alteredToken!.accessToken!) not similar to \(refetchedToken!.accessToken!)")
    }

    func testCreateTokensWithAllScopesAndStoreInKeychain() {
        let fullToken = mockTokenWithScope(kOauth2ScopeFull)
        let fullHighAuth = mockTokenWithScope(kOauth2ScopeFullHighAuth)
        let idPorten3 = mockTokenWithScope(kOauth2ScopeFull_Idporten3)
        let idPorten4 = mockTokenWithScope(kOauth2ScopeFull_Idporten4)
        let allTokens = OAuthToken.oAuthTokens()
        XCTAssertNil(idPorten3.refreshToken, "idporten3 token should not have refresh token")
        XCTAssertTrue(allTokens.count == 4, "token did not correctly store in database, should be 4, was \(allTokens.count)")
    }

    func testdeleteAllTokensInKeychain() {
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

    func testIfTokenExpiresAfterTimeOut() {
        let expectation = expectationWithDescription("Waiting for timeout on oauthToken")
        let timeout : NSTimeInterval = 8
        let oAuthDictionary = jsonDictionaryFromFile("ValidTokenExpiresSoon.json")
        let fullToken = OAuthToken(attributes: oAuthDictionary, scope: kOauth2ScopeFull, nonce: mockNonce)
        XCTAssertFalse(fullToken!.hasExpired(), "token expired before its time! time is \(NSDate()) and it expired \(fullToken?.expires)")


        dispatch(after: timeout - 3) {
            let fetchedToken = OAuthToken.oAuthTokenWithScope(kOauth2ScopeFull)
            XCTAssertFalse(fetchedToken!.hasExpired(), "token should not have expired yet, Time: \(NSDate()), it expires: \(fetchedToken?.expires)")
        }

        dispatch(after: timeout + 3) {
            let fetchedToken = OAuthToken.oAuthTokenWithScope(kOauth2ScopeFull)
            XCTAssertTrue(fetchedToken!.hasExpired(), "token should have expired! Time is \(NSDate()) and it expired \(fetchedToken?.expires)")
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(timeout + 5, handler: { (error) -> Void in
            XCTAssertNil(error, "\(error)")
        })
    }

    func testTokenDifferingNonceThanClient() {
        let invalidNonce = "invalidNonce"
        let invalidAuthDictionary = jsonDictionaryFromFile("ValidOAuthToken.json")
        let token = OAuthToken(attributes: invalidAuthDictionary, scope: kOauth2ScopeFullHighAuth, nonce: invalidNonce)
        XCTAssertNil(token, "should not be able to create token with differing nonce than provided")
    }

    func testTokenWithIDTokenWithDifferingAudThanClient() {
        let invalidAuthDictionary = jsonDictionaryFromFile("InvalidTokenDifferingAud.json")
        let token = OAuthToken(attributes: invalidAuthDictionary, scope: kOauth2ScopeFullHighAuth, nonce: mockNonce)
        XCTAssertNil(token, "should not be able to create token with differing aud than client")
    }

    func testTokenWithIDTokenWithDifferingSignatureThanClient() {
        let invalidAuthDictionary = jsonDictionaryFromFile("InvalidTokenDifferingSignature.json")
        let token = OAuthToken(attributes: invalidAuthDictionary, scope: kOauth2ScopeFullHighAuth, nonce: mockNonce)
        XCTAssertNil(token, "should not be able to create token with differing id_token signature than client")
    }

    func testRenewAccessTokensForMultipleDifferentTokens() {
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
