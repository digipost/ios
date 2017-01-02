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
    func keychainAccess(_ keychainAccess: LUKeychainAccess!, receivedError error: NSError!) {
        XCTAssertTrue(false, "got an error message \(error) from keychain")
    }

    func testKeepTokensWithDifferentScopesInKeychain() {
        mockTokenWithScope(kOauth2ScopeFull)
        // create an invalid token that does not get stored
        let invalidAuthDictionary = jsonDictionaryFromFile("ValidOAuthToken.json")
        _ = OAuthToken(attributes: invalidAuthDictionary, scope: kOauth2ScopeFullHighAuth, nonce: mockNonce)
        let allTokens = OAuthToken.oAuthTokens()
        XCTAssertTrue(allTokens.count == 2, "token did not correctly store in database")
    }

    // creates a token, fetches it from keychain, adds a new access token, then refetches to see if it did get updated
    func testUpdateSameTokenMultipleTimes() {
        let newAccessToken = "newAccessToken"
        mockTokenWithScope(kOauth2ScopeFull)
        
        let refetchedToken = OAuthToken.oAuthTokenWithScope(kOauth2ScopeFull)
        XCTAssertNotNil(refetchedToken, "no valid token was created")
        
        refetchedToken!.accessToken = newAccessToken
        
        let alteredToken = OAuthToken.oAuthTokenWithScope(kOauth2ScopeFull)
        //let acc = alteredToken?.accessToken!
        XCTAssertTrue(alteredToken!.accessToken! == refetchedToken!.accessToken!, "\(alteredToken!.accessToken!) not similar to \(refetchedToken!.accessToken!)")
    }

    func testCreateTokensWithAllScopesAndStoreInKeychain() {
        mockTokenWithScope(kOauth2ScopeFull)
        mockTokenWithScope(kOauth2ScopeFullHighAuth)
        let idPorten3 = mockTokenWithScope(kOauth2ScopeFull_Idporten3)
        mockTokenWithScope(kOauth2ScopeFull_Idporten4)
        let allTokens = OAuthToken.oAuthTokens()
        XCTAssertNil(idPorten3.refreshToken, "idporten3 token should not have refresh token")
        XCTAssertTrue(allTokens.count == 4, "token did not correctly store in database, should be 4, was \(allTokens.count)")
    }

    func testdeleteAllTokensInKeychain() {
        mockTokenWithScope(kOauth2ScopeFull)
        mockTokenWithScope(kOauth2ScopeFullHighAuth)
        mockTokenWithScope(kOauth2ScopeFull_Idporten3)
        mockTokenWithScope(kOauth2ScopeFull_Idporten4)
        let allTokens = OAuthToken.oAuthTokens()
        XCTAssertTrue(allTokens.count == 4, "token did not correctly store in database, should be 4, was \(allTokens.count)")
        
        OAuthToken.removeAllTokens()
        let allTokensAfterDeletion = OAuthToken.oAuthTokens()
        XCTAssertTrue(allTokensAfterDeletion.count == 0, "could not delete token database, should be 0, was \(allTokensAfterDeletion.count)")
    }

    func testIfTokenExpiresAfterTimeOut() {
        let expectation = self.expectation(description: "Waiting for timeout on oauthToken")
        let timeout : TimeInterval = 8
        let oAuthDictionary = jsonDictionaryFromFile("ValidTokenExpiresSoon.json")
        let fullToken = OAuthToken(attributes: oAuthDictionary, scope: kOauth2ScopeFull, nonce: mockNonce)
        XCTAssertFalse(fullToken!.hasExpired(), "token expired before its time! time is \(Date()) and it expired \(fullToken?.expires)")


        dispatch(after: timeout - 3) {
            let fetchedToken = OAuthToken.oAuthTokenWithScope(kOauth2ScopeFull)
            XCTAssertFalse(fetchedToken!.hasExpired(), "token should not have expired yet, Time: \(Date()), it expires: \(fetchedToken?.expires)")
        }

        dispatch(after: timeout + 3) {
            let fetchedToken = OAuthToken.oAuthTokenWithScope(kOauth2ScopeFull)
            XCTAssertTrue(fetchedToken!.hasExpired(), "token should have expired! Time is \(Date()) and it expired \(fetchedToken?.expires)")
            expectation.fulfill()
        }

        waitForExpectations(timeout: timeout + 5, handler: { (error) -> Void in
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
        mockTokenWithScope(kOauth2ScopeFull)
        mockTokenWithScope(kOauth2ScopeFullHighAuth)
        mockTokenWithScope(kOauth2ScopeFull_Idporten3)
        mockTokenWithScope(kOauth2ScopeFull_Idporten4)

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
