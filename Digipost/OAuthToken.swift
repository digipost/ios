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
    
    required convenience init(coder decoder: NSCoder) {
        self.init()
        self.refreshToken = decoder.decodeObjectForKey(Keys.refreshTokenKey) as String!
        self.accessToken = decoder.decodeObjectForKey(Keys.accessTokenKey) as String!
        self.scope = decoder.decodeObjectForKey(Keys.scopeKey) as String!
        println(self)
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.refreshToken, forKey: Keys.refreshTokenKey)
        coder.encodeObject(self.accessToken, forKey: Keys.accessTokenKey)
        coder.encodeObject(self.scope, forKey: Keys.scopeKey)
        println(self.refreshToken)
        println(self.accessToken)
    }
    
    convenience init?(refreshToken: String?, accessToken: String?, scope:String) {
        self.init()
        
        if let acutalRefreshToken = refreshToken as String? {
           self.refreshToken = acutalRefreshToken
        }
        
        if let actualAccessToken = accessToken as String? {
            self.accessToken = actualAccessToken
        }else {
            return nil
        }
        self.scope = scope
        storeInKeyChain()
    }
    
    convenience init?(attributes: Dictionary<String,AnyObject>, scope: String) {
        var aRefreshToken: String?
        var anAccessToken: String?
        aRefreshToken = attributes["refresh_token"] as String?
        anAccessToken = attributes["access_token"] as String?
        self.init(refreshToken: aRefreshToken, accessToken: anAccessToken, scope: scope)
        storeInKeyChain()
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