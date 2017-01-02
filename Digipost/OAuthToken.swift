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

class OAuthToken: NSObject, NSCoding {

    var refreshToken: String? {
        didSet {
            storeInKeyChain()
        }
    }

    var accessToken: String? {
        didSet {
            storeInKeyChain()
        }
    }

    var expires : Date

    var scope: String?

    init(expiryDate: Date) {
        self.expires = expiryDate
        super.init()
    }

    required convenience init(coder decoder: NSCoder) {
        // If token is archived without expirydate, for example if upgrading from an older client, set expirydate to now(), to force reauthentication
        let expires : Date = {
            if let expiryDate =  decoder.decodeObject(forKey: Keys.expiresKey) as? Date {
                return expiryDate
            } else {
                return Date()
            }
            }()
        self.init(expiryDate: expires)
        self.scope = decoder.decodeObject(forKey: Keys.scopeKey) as! String!
        self.refreshToken = decoder.decodeObject(forKey: Keys.refreshTokenKey) as? String
        self.accessToken = decoder.decodeObject(forKey: Keys.accessTokenKey) as? String
    }

    // Initializer used when migrating from single scope to multiple scopes - version 2.3
    convenience init?(refreshToken: String?, scope: String) {
        self.init(refreshToken: refreshToken, accessToken: nil, scope: scope, expiresInSeconds: 1)
        if refreshToken == nil {
            self.removeFromKeychainIfNoAccessToken()
            return nil
        }
        storeInKeyChain()
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
        storeInKeyChain()
    }

    convenience init?(attributes: Dictionary <String,AnyObject>, scope: String, nonce: String) {
        var aRefreshToken: String?
        var anAccessToken: String?
        aRefreshToken = attributes["refresh_token"] as? String
        anAccessToken = attributes["access_token"] as? String
        let idToken = attributes[kOAuth2IDToken] as? String
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
        storeInKeyChain()
    }

    // bug in swift compiler requires to set all instance variables before returning nil from an initializer
    fileprivate func setAllInstanceVariablesToNil() {
        self.refreshToken = nil
        self.accessToken = nil
        self.scope = nil
    }

    class func levelForScope(_ aScope: String)-> Int {
        switch aScope {
        case kOauth2ScopeFull:
            return 1
        case kOauth2ScopeFullHighAuth:
            fallthrough
        case kOauth2ScopeFull_Idporten3:
            return 2
        case kOauth2ScopeFull_Idporten4:
            return 3
        default:
            return 1
        }
    }

    class func highestScopeInStorageForScope(_ scope:String) -> String {
        switch scope {
        case kOauth2ScopeFull_Idporten4:
            return scope
        case kOauth2ScopeFull_Idporten3:
            if let higherLevelToken = oAuthTokenWithScope(kOauth2ScopeFull_Idporten4) {
                if higherLevelToken.accessToken != nil {
                    return kOauth2ScopeFull_Idporten4
                }else {
                    return scope
                }
            } else if let idporten3Token = oAuthTokenWithScope(kOauth2ScopeFull_Idporten3) {
                return idporten3Token.scope!
            } else {
                return kOauth2ScopeFull
            }
        case kOauth2ScopeFullHighAuth:
            if let higherLevelToken = oAuthTokenWithScope(kOauth2ScopeFull_Idporten4) {
                if higherLevelToken.accessToken != nil {
                    return kOauth2ScopeFull_Idporten4
                } else {
                    return scope
                }
            } else if let highAuthToken = oAuthTokenWithScope(kOauth2ScopeFullHighAuth) {
                return highAuthToken.scope!
            } else {
                return kOauth2ScopeFull
            }
        default:
            return scope
        }
    }

    class func oAuthTokenWithHigestScopeInStorage() -> OAuthToken? {
        if let token = oAuthTokenWithScope(kOauth2ScopeFull_Idporten4) {
            return token
        }else if let token = oAuthTokenWithScope(kOauth2ScopeFull_Idporten3) {
            return token
        }else if let token = oAuthTokenWithScope(kOauth2ScopeFullHighAuth) {
            return token
        }else {
            return oAuthTokenWithScope(kOauth2ScopeFull)
        }
    }

    func encode(with coder: NSCoder) {
        coder.encode(self.refreshToken, forKey: Keys.refreshTokenKey)
        coder.encode(self.accessToken, forKey: Keys.accessTokenKey)
        coder.encode(self.scope, forKey: Keys.scopeKey)
        coder.encode(self.expires, forKey: Keys.expiresKey)
    }

    func setExpireDate(_ expiresInSeconds: NSNumber?) {
        if let actualExpirationDate = expiresInSeconds as NSNumber? {
            if let expirationDate = Date().dateByAdding(seconds: actualExpirationDate.intValue) {
                self.expires = expirationDate
                storeInKeyChain()
            }
        }
    }

    class func isUserLoggedIn() -> Bool {
        return OAuthToken.oAuthTokenWithScope(kOauth2ScopeFull) != nil
    }

    func removeFromKeychainIfNoAccessToken() {
        if accessToken == nil {
            var existingTokens = OAuthToken.oAuthTokens()
            existingTokens[scope!] = nil
            LUKeychainAccess.standard().setObject(existingTokens, forKey: kOAuth2TokensKey)
        }
    }

    func removeFromKeyChainIfNotValid() {
        if accessToken == nil && refreshToken == nil {
            removeFromKeychainIfNoAccessToken()
        }
    }

    func password() -> String? {
        return scope == kOauth2ScopeFull ? refreshToken : accessToken
    }

    func storeInKeyChain() {
        var existingTokens = OAuthToken.oAuthTokens()
        if let actualScope = scope {
            existingTokens[actualScope] = self
            LUKeychainAccess.standard().setObject(existingTokens, forKey: kOAuth2TokensKey)
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

    func canBeRefreshedByRefreshToken() -> Bool {
        return scope == kOauth2ScopeFull
    }

    class func moveOldOAuthTokensIfPresent() {
        if ((LUKeychainAccess.standard().string(forKey: kKeychainAccessRefreshTokenKey) as String?) != nil) {
            LUKeychainAccess.standard().setObject(nil, forKey: kKeychainAccessRefreshTokenKey)
        }
    }

    class func oAuthTokenWithHighestScopeInStorage() -> OAuthToken? {
        if let oAuth4Token = oAuthTokenWithScope(kOauth2ScopeFull_Idporten4) {
            return oAuth4Token
        }else if let oAuth3Token = oAuthTokenWithScope(kOauth2ScopeFull_Idporten3) {
            return oAuth3Token
        }else if let oAuthTwoFactorToken = oAuthTokenWithScope(kOauth2ScopeFullHighAuth){
            return oAuthTwoFactorToken
        }else {
            return oAuthTokenWithScope(kOauth2ScopeFull)
        }
    }

    class func highestOAuthTokenWithScope(_ scope: String) -> OAuthToken? {
        let level = levelForScope(scope)
        switch level {
        case 2:
            if let higherLevelToken = oAuthTokenWithScope(kOauth2ScopeFull_Idporten4) {
                if higherLevelToken.accessToken != nil {
                    return higherLevelToken
                }else {
                    return oAuthTokenWithScope(scope)
                }
            } else {
                return oAuthTokenWithScope(scope)
            }
        case 3:
            return oAuthTokenWithScope(scope)
        default:
            return oAuthTokenWithScope(scope)
        }
    }

    class func oAuthTokenWithScope(_ scope: String) -> OAuthToken? {
        let dictionary = LUKeychainAccess.standard().object(forKey: kOAuth2TokensKey) as! NSDictionary?
        if let actualDictionary = dictionary as NSDictionary? {
            if let token = actualDictionary[scope] as?  OAuthToken? {
                return token
            }
        }
        return nil
    }

    class func oAuthTokens() -> Dictionary<String,AnyObject> {
        var tokenArray = Dictionary<String,AnyObject>()
        let dictionary = LUKeychainAccess.standard().object(forKey: kOAuth2TokensKey) as! NSDictionary?
        if let actualDictionary = dictionary {
            for key in actualDictionary.allKeys {
                if let actualKey = key as? String {
                    let object: AnyObject = actualDictionary[actualKey]! as AnyObject
                    tokenArray[actualKey] = object
                }
            }
        }
        return tokenArray
    }
    
    class func oAuthScope(_ scope: String, isHigherThanOrEqualToScope otherScope: String) -> Bool {
        switch otherScope {
        case kOauth2ScopeFull:
            if scope != kOauth2ScopeFull {
                return true
            }
        case kOauth2ScopeFullHighAuth:
            switch scope {
            case kOauth2ScopeFull_Idporten4:
                fallthrough
            case kOauth2ScopeFull_Idporten3:
                return true
            case kOauth2ScopeFullHighAuth:
                return true
            default:
                return false
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

    class func oAuthScopeForAuthenticationLevel(_ authenticationLevel: String?) -> String {
        if let actualAuthenticationLevel = authenticationLevel {
            switch actualAuthenticationLevel {
            case AuthenticationLevel.password:
                return kOauth2ScopeFull
            case AuthenticationLevel.twoFactor:
                return kOauth2ScopeFullHighAuth
            case AuthenticationLevel.idPorten3:
                return kOauth2ScopeFull_Idporten3;
            case AuthenticationLevel.idPorten4:
                return kOauth2ScopeFull_Idporten4
            default:
                break
            }
        }
        return kOauth2ScopeFull
    }

    class func removeAllTokens() {
        let emptyDictionary = Dictionary<String,AnyObject>()
        LUKeychainAccess.standard().setObject(emptyDictionary, forKey: kOAuth2TokensKey)
    }

    class func removeAccessTokenForOAuthTokenWithScope(_ scope: String) {
        let oauthToken = OAuthToken.oAuthTokenWithScope(scope)
        oauthToken?.accessToken = nil
    }
}
