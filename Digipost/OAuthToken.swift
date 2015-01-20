//
//  OAuthToken.swift
//  Digipost
//
//  Created by Håkon Bogen on 26/11/14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

import Foundation

private struct Keys {
    static let refreshTokenKey = "refreshToken"
    static let accessTokenKey = "accessToken"
    static let scopeKey = "scope"
}

class OAuthToken: NSObject, NSCoding{
    
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
    
    var scope: String?
    
    class func levelForScope(aScope: String)-> Int {
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
    
    class func highestScopeInStorageForScope(scope:String) -> String {
        switch scope {
        case kOauth2ScopeFull_Idporten4:
            return scope
        case kOauth2ScopeFull_Idporten3:
            fallthrough
        case kOauth2ScopeFullHighAuth:
            if let higherLevelToken = oAuthTokenWithScope(kOauth2ScopeFull_Idporten4) {
                if higherLevelToken.accessToken != nil {
                    return kOauth2ScopeFull_Idporten4
                }else {
                    return scope
                }
            }else {
                return scope
            }
        default:
            return scope
        }
    }
        
    required convenience init(coder decoder: NSCoder) {
        self.init()
        self.refreshToken = decoder.decodeObjectForKey(Keys.refreshTokenKey) as String!
        self.accessToken = decoder.decodeObjectForKey(Keys.accessTokenKey) as String!
        self.scope = decoder.decodeObjectForKey(Keys.scopeKey) as String!
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.refreshToken, forKey: Keys.refreshTokenKey)
        coder.encodeObject(self.accessToken, forKey: Keys.accessTokenKey)
        coder.encodeObject(self.scope, forKey: Keys.scopeKey)
    }
    convenience init?(refreshToken: String?, scope: String) {
         self.init()
        
        if let acutalRefreshToken = refreshToken as String? {
           self.refreshToken = acutalRefreshToken
        } else {
            return nil
        }
        
        self.scope = scope
        storeInKeyChain()
    }
    
    convenience init?(refreshToken: String?, accessToken: String?, scope:String) {
        self.init()
        
        if let acutalRefreshToken = refreshToken as String? {
           self.refreshToken = acutalRefreshToken
        }
        
        if let actualAccessToken = accessToken as String? {
            self.accessToken = actualAccessToken
        }
        self.scope = scope
        storeInKeyChain()
    }
    
    convenience init?(attributes: Dictionary<String,AnyObject>, scope: String) {
        var aRefreshToken: String?
        var anAccessToken: String?
        aRefreshToken = attributes["refresh_token"] as? String
        anAccessToken = attributes["access_token"] as? String
        self.init(refreshToken: aRefreshToken, accessToken: anAccessToken, scope: scope)
        storeInKeyChain()
    }
    
    func password() -> String? {
        if scope == kOauth2ScopeFull{
            return refreshToken
        }else {
            return accessToken
        }
    }
    
    func storeInKeyChain() {
        var existingTokens = OAuthToken.oAuthTokens()
        existingTokens[scope!] = self
        LUKeychainAccess.standardKeychainAccess().setObject(existingTokens, forKey: kOAuth2TokensKey)
    }
    
    func canBeRefreshedByRefreshToken() -> Bool {
        if scope == kOauth2ScopeFull {
            return true
        }
        return false
    }
    
    class func moveOldOAuthTokensIfPresent() {
        if let actualOldRefreshToken = LUKeychainAccess.standardKeychainAccess().stringForKey(kKeychainAccessRefreshTokenKey) as String? {
            let newOAuthToken = OAuthToken(refreshToken: actualOldRefreshToken, scope: kOauth2ScopeFull)
            LUKeychainAccess.standardKeychainAccess().setObject(nil, forKey: kKeychainAccessRefreshTokenKey)
        }
    }
    
    class func highestOAuthTokenWithScope(scope: String) -> OAuthToken? {
        let level = levelForScope(scope)
        switch level {
        case 2:
            if let higherLevelToken = oAuthTokenWithScope(kOauth2ScopeFull_Idporten4) {
                if higherLevelToken.accessToken != nil {
                    return higherLevelToken
                }else {
                    return oAuthTokenWithScope(scope)
                }
            }else {
                return oAuthTokenWithScope(scope)
            }
        case 3:
            return oAuthTokenWithScope(scope)
        default:
            return oAuthTokenWithScope(scope)
        }
    }
    
    class func oAuthTokenWithScope(scope: String) -> OAuthToken? {
        let dictionary = LUKeychainAccess.standardKeychainAccess().objectForKey(kOAuth2TokensKey) as NSDictionary?
        if let actualDictionary = dictionary as NSDictionary? {
            let object: AnyObject! = actualDictionary[scope] as AnyObject!
            if object != nil {
                return object as OAuthToken!
            }
        }
        return nil
    }
    
    class func oAuthTokens() -> Dictionary<String,AnyObject> {
        var tokenArray = Dictionary<String,AnyObject>()
        let dictionary = LUKeychainAccess.standardKeychainAccess().objectForKey(kOAuth2TokensKey) as NSDictionary?
        if let actualDictionary = dictionary as NSDictionary? {
            for key in actualDictionary.allKeys as [String] {
                let object: AnyObject = actualDictionary[key] as AnyObject!
                tokenArray[key] = object
            }
        }
        return tokenArray
    }
    
    class func oAuthScopeForAuthenticationLevel(authenticationLevel: String) -> String {
        switch authenticationLevel {
        case "PASSWORD":
            return kOauth2ScopeFull
        case "TWO_FACTOR":
            return kOauth2ScopeFullHighAuth
        case "IDPORTEN_4":
            return kOauth2ScopeFull_Idporten4
        default:
            return authenticationLevel
        }
    }
    
    class func removeAllTokens() {
        let emptyDictionary = Dictionary<String,AnyObject>()
        LUKeychainAccess.standardKeychainAccess().setObject(emptyDictionary, forKey: kOAuth2TokensKey)
    }
    
    class func removeAcessTokenForOAuthTokenWithScope(scope: String) {
        let oauthToken = OAuthToken.oAuthTokenWithScope(scope)
        oauthToken?.accessToken = nil
    }
    
}