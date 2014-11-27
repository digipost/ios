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
    
//    var rank: Int = 0 {
//        didSet {
//            // Say 1000 is not good for you and 999 is the maximum you want to be stored there
//            if rank >= 1000  {
//                rank = 999
//            }
//        }
//    }
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
            println(self.refreshToken)
        } else {
            return nil
        }
        if let actualAccessToken = accessToken as String? {
            self.accessToken = actualAccessToken
            println(self.accessToken)
        }else {
            return nil
        }
        self.scope = scope
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
        default:
            assert(false, "wrong auth level")
            return kOauth2ScopeFull
        }
    }
    
    class func removeAllTokens() {
        assert(false, "not implemented")
    }
    
    class func removeAcessTokenForOAuthTokenWithScope(scope: String) {
        let oauthToken = OAuthToken.oAuthTokenWithScope(scope)
        oauthToken?.accessToken = nil
    }

}