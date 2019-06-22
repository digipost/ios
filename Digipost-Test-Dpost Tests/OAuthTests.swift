//
// Copyright (C) Posten Norge AS
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//         http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import UIKit
import XCTest
import LUKeychainAccess
@testable import Digipost

class OAuthTests: XCTestCase, LUKeychainErrorHandler {
    
    override func setUp() {
        super.setUp()
        OAuthToken.removeAllTokens()
    }
    
    override func tearDown() {
        super.tearDown()
        OAuthToken.removeAllTokens()
    }
    
    func jsonDictionaryFromFile(_ filename: String) -> Dictionary<String, AnyObject> {
        let testBundle = Bundle(for: OAuthTests.self)
        let path = testBundle.path(forResource: filename, ofType: nil)
        XCTAssertNotNil(path, "wrong filename")
        let data = try? Data(contentsOf: URL(fileURLWithPath: path!))
        XCTAssertNotNil(data, "wrong filename")
        do{
            let jsonDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! Dictionary<String,AnyObject>
            return jsonDictionary
        }catch let error{
            XCTAssertNil(error, "could not read json")
            return Dictionary<String, AnyObject>()
        }
    }
    
    var mockNonce = "-880201503"
    
    func mockTokenWithScope(_ scope: String) -> OAuthToken {
        
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
    func keychainAccess(_ keychainAccess: LUKeychainAccess!, receivedError error: Error!) {
        XCTAssertTrue(false, "got an error message \(error) from keychain")
    }
    
    func getTokenArray() -> Dictionary<String,AnyObject> {
        var allTokens = Dictionary<String,AnyObject>()
        if let token = OAuthToken.getToken() {
            allTokens[token.scope!] = token
        }
        return allTokens
    }
    
    func testKeepTokensWithDifferentScopesInKeychain() {
        _ = mockTokenWithScope(kOauth2ScopeFull)
        // create an invalid token that does not get stored
        let invalidAuthDictionary = jsonDictionaryFromFile("ValidOAuthToken.json")
        _ = OAuthToken(attributes: invalidAuthDictionary, scope: kOauth2ScopeFullHighAuth, nonce: mockNonce)
        var allTokens = getTokenArray()
        XCTAssertTrue(allTokens.count == 2, "token did not correctly store in database")
    }
    
    func testCreateTokensWithAllScopesAndStoreInKeychain() {
        _ = mockTokenWithScope(kOauth2ScopeFull)
        _ = mockTokenWithScope(kOauth2ScopeFullHighAuth)
        let idPorten3 = mockTokenWithScope(kOauth2ScopeFull_Idporten3)
        _ = mockTokenWithScope(kOauth2ScopeFull_Idporten4)
        var allTokens = getTokenArray()
        XCTAssertNil(idPorten3.refreshToken, "idporten3 token should not have refresh token")
        XCTAssertTrue(allTokens.count == 4, "token did not correctly store in database, should be 4, was \(allTokens.count)")
    }
    
    func testdeleteAllTokensInKeychain() {
        _ = mockTokenWithScope(kOauth2ScopeFull)
        _ = mockTokenWithScope(kOauth2ScopeFullHighAuth)
        _ = mockTokenWithScope(kOauth2ScopeFull_Idporten3)
        _ = mockTokenWithScope(kOauth2ScopeFull_Idporten4)
        let allTokens = getTokenArray()
        XCTAssertTrue(allTokens.count == 4, "token did not correctly store in database, should be 4, was \(allTokens.count)")
        
        OAuthToken.removeAllTokens()
        let allTokensAfterDeletion = getTokenArray()
        XCTAssertTrue(allTokensAfterDeletion.count == 0, "could not delete token database, should be 0, was \(allTokensAfterDeletion.count)")
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
    
    func testFetchTokensFromList(){
        let _ = mockTokenWithScope(kOauth2ScopeFull)        
        let tokens = getTokenArray()
        XCTAssert(tokens.count == 1, "count should be 1")
        let token = tokens[kOauth2ScopeFull]
        XCTAssertNotNil(token, "should not be nil")
    }
    
    func testStringInKeychainAccess(){
        let testKey = "TEST"
        LUKeychainAccess.standard().setObject(testKey, forKey: testKey)
        let key = LUKeychainAccess.standard().object(forKey: testKey) as! String        
        XCTAssertEqual(testKey, key, "should be equal ")
    }
    
    func testObjectInKeychainAccess(){
        let testKey = "TEST"
        let mockToken = mockTokenWithScope(kOauth2ScopeFull)  
        
        LUKeychainAccess.standard().setObject(mockToken, forKey: testKey)
        let fetched = LUKeychainAccess.standard().object(forKey: testKey)
        
        if let fetchedToken = fetched as? OAuthToken {
            XCTAssertEqual(mockToken.accessToken, fetchedToken.accessToken, "should be equal ")
        } else {
            XCTAssertTrue(false, "cast failed")
        }
    }
    
    func testFetchTokenWithScope(){
        let _ = mockTokenWithScope(kOauth2ScopeFull)        
        let fetched = OAuthToken.oAuthTokenWithScope(kOauth2ScopeFull)! as OAuthToken
        XCTAssertNotNil(fetched, "should not be nil")
    }
    
    func testFetchedTokenIsValid(){
        let _ = mockTokenWithScope(kOauth2ScopeFull)        
        
        if let fetched = OAuthToken.oAuthTokenWithScope(kOauth2ScopeFull) {
            XCTAssertNotNil(fetched.accessToken, "should not be nil")
        } else {
            XCTAssert(false, "fetched should exist")
        }
    }
    
    // creates a token, fetches it from keychain, adds a new access token, then refetches to see if it did get updated
    func testUpdateSameTokenMultipleTimes() {
        let newAccessToken = "newAccessToken"
        let _ = mockTokenWithScope(kOauth2ScopeFull)
        
        let refetchedToken = getTokenArray()[kOauth2ScopeFull] as! OAuthToken
        
        XCTAssertNotNil(refetchedToken, "should not be nil")
        refetchedToken.accessToken = newAccessToken
        
        let alteredToken = getTokenArray()[kOauth2ScopeFull] as! OAuthToken
        
        XCTAssertTrue(alteredToken.accessToken! == refetchedToken.accessToken!, "\(alteredToken.accessToken!) not similar to \(refetchedToken.accessToken!)")
    }
    
    func testRenewAccessTokenToken(){
        let newAccessTokenFull = "new Accesstoken for Full"        
        let oAuthDictionary = jsonDictionaryFromFile("ValidOAuthToken.json")
        
        _ = OAuthToken(attributes: oAuthDictionary, scope: kOauth2ScopeFull, nonce: mockNonce)
        
        let fetchedFull = OAuthToken.oAuthTokenWithScope(kOauth2ScopeFull)
        fetchedFull?.accessToken = newAccessTokenFull
        let refetchedFull = OAuthToken.oAuthTokenWithScope(kOauth2ScopeFull)        
        XCTAssertEqual(refetchedFull!.accessToken!, newAccessTokenFull, "did not save new access token correctly")
    }
    
    func testRenewAccessTokensForMultipleDifferentTokens() {
        let newAccessTokenFull = "new Accesstoken for Full"
        let newAccessTokenHighAuth = "new Acesstoken for HighAuth"
        let newAccessTokenIdPorten4 = "new Acesstoken for idporten4"
        _ = mockTokenWithScope(kOauth2ScopeFull)
        _ = mockTokenWithScope(kOauth2ScopeFullHighAuth)
        _ = mockTokenWithScope(kOauth2ScopeFull_Idporten3)
        _ = mockTokenWithScope(kOauth2ScopeFull_Idporten4)
        
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
    
    func testIfTokenExpiresAfterTimeOut() {
        let expectation = self.expectation(description: "Waiting for timeout on oauthToken")
        let timeout : TimeInterval = 8
        let oAuthDictionary = jsonDictionaryFromFile("ValidTokenExpiresSoon.json")
        _ = OAuthToken(attributes: oAuthDictionary, scope: kOauth2ScopeFull, nonce: mockNonce)
        let fullToken = OAuthToken(attributes: oAuthDictionary, scope: kOauth2ScopeFullHighAuth, nonce: mockNonce)
        XCTAssertFalse(fullToken!.hasExpired(), "token expired before its time! time is \(Date()) and it expired \(fullToken?.expires)")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
            let fetchedToken = OAuthToken.oAuthTokenWithScope(kOauth2ScopeFull)
            XCTAssertFalse(fetchedToken!.hasExpired(), "token should not have expired yet, Time: \(Date()), it expires: \(fetchedToken?.expires)")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(11)) {
            let fetchedToken = OAuthToken.oAuthTokenWithScope(kOauth2ScopeFull)
            XCTAssertTrue(fetchedToken!.hasExpired(), "token should have expired! Time is \(Date()) and it expired \(fetchedToken?.expires)")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout + 5) { (error) in
            XCTAssertNil(error, "not successfull ")
        }
    }
}
