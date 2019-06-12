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

import Foundation
import LUKeychainAccess

private struct Keys {
    static let refreshTokenKey = "refreshToken"
    static let accessTokenKey = "accessToken"
    static let scopeKey = "scope"
    static let expiresKey = "expires"
}

struct AuthenticationLevel {
    static let password = "PASSWORD"
    static let twoFactor = "TWO_FACTOR"
    static let idPorten4 = "IDPORTEN_4"
    static let idPorten3 = "IDPORTEN_3"
}

@objc class OAuthToken: NSObject, NSCoding {
    func encode(with aCoder: NSCoder) {
        //
    }
    
    @objc var refreshToken: String? {
        didSet {
            saveToken()
        }
    }
    
    @objc var accessToken: String? {
        didSet {
            saveToken()
        }
    }
    
    var expires : Date
    
    @objc var scope: String?
    
    init(expiryDate: Date) {
        self.expires = expiryDate
        super.init()
    }
    
    required convenience public init(coder decoder: NSCoder) {
        self.init(expiryDate: decoder.decodeObject(forKey: Keys.expiresKey) as! Date)
        self.scope = decoder.decodeObject(forKey: Keys.scopeKey) as? String
        self.refreshToken = decoder.decodeObject(forKey: Keys.refreshTokenKey) as? String
        self.accessToken = decoder.decodeObject(forKey: Keys.accessTokenKey) as? String
    }
    
    func saveToken() {
        LUKeychainAccess.standard().setObject(self, forKey: kOAuth2Token)
    }
    
    class func getToken() -> OAuthToken? {
        return LUKeychainAccess.standard().object(forKey: kOAuth2Token) as? OAuthToken
    }
    
    @objc class func removeToken() {
        LUKeychainAccess.standard().deleteObject(forKey: kOAuth2Token)
    }
    
    @objc class func isUserLoggedIn() -> Bool {
        return OAuthToken.getToken() != nil
    }
    
    @objc class func oAuthScopeForAuthenticationLevel(_ authenticationLevel: String?) -> String {
        return authenticationLevel! == AuthenticationLevel.password ? kOauth2ScopeFull : kOauth2ScopeFull_Idporten4
    }
    
    @objc class func oAuthTokenWithScope(_ scope: String) -> OAuthToken? {
        if let token = OAuthToken.getToken() {
            if token.scope == scope{
                return token
            }
        }
        return nil
    }
    
    @objc class func highestScopeInStorageForScope(_ scope:String) -> String {
        if let token = OAuthToken.getToken() {
            return token.scope!
        }
        return kOauth2ScopeFull
    }
    
    @objc class func oAuthScope(_ scope: String, isHigherThanOrEqualToScope otherScope: String) -> Bool {
        switch otherScope {
        case kOauth2ScopeFull:
            if scope != kOauth2ScopeFull {
                return true
            }
        case kOauth2ScopeFull_Idporten3:
            if scope == kOauth2ScopeFull_Idporten4 {
                return true
            }
            return false
        case kOauth2ScopeFull_Idporten4:
            return false
        default:
            return false
        }
        return false
    }
    
    func removeFromKeyChainIfNotValid() {
        if accessToken == nil && refreshToken == nil {
            OAuthToken.removeToken()
        }
    }
    
    func hasExpired() -> Bool {
        if accessToken == nil {
            return true
        }
        let todayDate = Date()
        if expires.isLaterThan(todayDate) {
            return false
        }
        return true
    }
    
    @objc func removeFromKeychainIfNoAccessToken() {
        //TODO REVURDER
        if accessToken == nil {
            OAuthToken.removeToken()
        }
    }
    
    @objc class func removeAllTokens() {
        //TODO REVURDER
        OAuthToken.removeToken()
    }
    
    @objc class func removeAccessTokenForOAuthTokenWithScope(_ scope:String) {
        //TODO REMOVE
        OAuthToken.removeToken()
    }
    
}
