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
    
    public func encode(with coder: NSCoder) {
        coder.encode(self.refreshToken, forKey: Keys.refreshTokenKey)
        coder.encode(self.accessToken, forKey: Keys.accessTokenKey)
        coder.encode(self.scope, forKey: Keys.scopeKey)
        coder.encode(self.expires, forKey: Keys.expiresKey)
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
        let expires : Date = {
            if let expiryDate =  decoder.decodeObject(forKey: Keys.expiresKey) as? Date {
                return expiryDate
            } else {
                return Date()
            }
        }()
        self.init(expiryDate: expires)
        self.scope = decoder.decodeObject(forKey: Keys.scopeKey) as? String
        self.refreshToken = decoder.decodeObject(forKey: Keys.refreshTokenKey) as? String
        self.accessToken = decoder.decodeObject(forKey: Keys.accessTokenKey) as? String
    }
    
    // Initializer used when migrating from single scope to multiple scopes - version 2.3
    convenience init?(refreshToken: String?, scope: String) {
        self.init(refreshToken: refreshToken, accessToken: nil, scope: scope, expiresInSeconds: 1)
        saveToken()
    }
    
    fileprivate init?(refreshToken: String?, accessToken: String?, scope: String, expiresInSeconds: NSNumber) {
        if let expirationDate = Date().dateByAdding(seconds: expiresInSeconds.intValue) {
            self.expires = expirationDate
        } else {
            self.expires = Date()
            super.init()
            self.setAllInstanceVariablesToNil()
            return nil
        }
        if let acutalRefreshToken = refreshToken as String? {
            self.refreshToken = acutalRefreshToken
        }
        
        if let actualAccessToken = accessToken as String? {
            self.accessToken = actualAccessToken
        }
        self.scope = scope
        super.init()
        saveToken()
    }

    @objc convenience init?(attributes: Dictionary <String,AnyObject>, nonce: String) {
        var aRefreshToken: String?
        var anAccessToken: String?
        aRefreshToken = attributes["refresh_token"] as? String
        anAccessToken = attributes["access_token"] as? String
        let idToken = attributes[kOAuth2IDToken] as? String
        let scope = attributes["scope"] as! String
        if OAuthToken.isIdTokenValid(idToken, nonce: nonce) == false {
            self.init(expiryDate: Date())
            self.setAllInstanceVariablesToNil()
            return nil
        }
        
        if let expiresInSeconds = attributes["expires_in"] as? NSNumber {
            self.init(refreshToken: aRefreshToken, accessToken: anAccessToken, scope: scope, expiresInSeconds:expiresInSeconds)
        } else {
            self.init(expiryDate: Date())
            self.setAllInstanceVariablesToNil()
            return nil
        }
        saveToken()
    }
    
    // bug in swift compiler requires to set all instance variables before returning nil from an initializer
    fileprivate func setAllInstanceVariablesToNil() {
        self.refreshToken = nil
        self.accessToken = nil
        self.scope = nil
    }
    
    func saveToken() {
        LUKeychainAccess.standard().setObject(self, forKey: kOAuth2Token)
    }
    
    @objc class func getToken() -> OAuthToken? {
        return LUKeychainAccess.standard().object(forKey: kOAuth2Token) as? OAuthToken
    }
    
    @objc class func removeToken() {
        if self.getToken() != nil {
            LUKeychainAccess.standard().deleteObject(forKey: kOAuth2Token)
        }
    }
    
    @objc class func isUserLoggedIn() -> Bool {
        return OAuthToken.getToken() != nil
    }
    
    @objc class func oAuthScopeForAuthenticationLevel(_ authenticationLevel: String?) -> String {
        return authenticationLevel! == AuthenticationLevel.password ? kOauth2ScopeFull : kOauth2ScopeFull_Idporten4
    }
    
    @objc class func oAuthTokenWithScope(_ scope: String) -> OAuthToken? {
        if let token = OAuthToken.getToken() {
            if (token.scope == kOauth2ScopeFull_Idporten4){
                return token
            }else if (scope == token.scope){
                return token
            }else if(scope == kOauth2ScopeFull && token.scope == kOauth2ScopeFull_Idporten3){
                return token
            }
        }
        return nil
    }

    @objc class func
        oAuthTokenWithAuthenticationLevel(_ authenticationLevel: String) -> OAuthToken? {
        switch authenticationLevel {
        case AuthenticationLevel.password :
            return OAuthToken.oAuthTokenWithScope(kOauth2ScopeFull)
        case AuthenticationLevel.twoFactor :
            return oAuthTokenWithScope(kOauth2ScopeFullHighAuth)
        case AuthenticationLevel.idPorten3:
            return oAuthTokenWithScope(kOauth2ScopeFull_Idporten3)
        case AuthenticationLevel.idPorten4 :
            return oAuthTokenWithScope(kOauth2ScopeFull_Idporten4)
        default:
            return OAuthToken.oAuthTokenWithScope(kOauth2ScopeFull)
        }
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
        if let token = OAuthToken.getToken() {
            if token.accessToken == nil && token.refreshToken == nil {
                OAuthToken.removeToken()
            }
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
    
    @objc func setAccessTokenAndScope(_ accessToken: NSString, scope: NSString) {
        self.accessToken = accessToken as String
        self.scope = scope as String
        saveToken()
    }
    
    @objc func setExpireDate(_ expiresInSeconds: NSNumber?) {
        if let actualExpirationDate = expiresInSeconds as NSNumber? {
            if let expirationDate = Date().dateByAdding(seconds: actualExpirationDate.intValue) {
                self.expires = expirationDate
                saveToken()
            }
        }
    }
    
    @objc func password() -> String? {
        return refreshToken
    }
}
