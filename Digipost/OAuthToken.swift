//
//  OAuthToken.swift
//  Digipost
//
//  Created by Håkon Bogen on 26/11/14.
//  Copyright (c) 2014 Posten. All rights reserved.
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

class OAuthToken: NSObject, NSCoding, DebugPrintable, Printable{

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

    var expires : NSDate?

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

    required convenience init(coder decoder: NSCoder) {
        self.init()
        self.refreshToken = decoder.decodeObjectForKey(Keys.refreshTokenKey) as! String!
        self.accessToken = decoder.decodeObjectForKey(Keys.accessTokenKey) as! String!
        self.scope = decoder.decodeObjectForKey(Keys.scopeKey) as! String!
        self.expires = decoder.decodeObjectForKey(Keys.expiresKey) as! NSDate!
    }

    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.refreshToken, forKey: Keys.refreshTokenKey)
        coder.encodeObject(self.accessToken, forKey: Keys.accessTokenKey)
        coder.encodeObject(self.scope, forKey: Keys.scopeKey)
        coder.encodeObject(self.expires, forKey: Keys.expiresKey)
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

    convenience init?(refreshToken: String?, accessToken: String?, scope:String, expiresInSeconds: NSNumber?) {
        self.init()

        if let acutalRefreshToken = refreshToken as String? {
            self.refreshToken = acutalRefreshToken
        }

        if let actualAccessToken = accessToken as String? {
            self.accessToken = actualAccessToken
        }
        if let actualExpirationDate = expiresInSeconds as NSNumber? {
            let expirationDate = NSDate().dateByAdding(seconds: actualExpirationDate.integerValue)
            self.expires = expirationDate
        }

        self.scope = scope
        storeInKeyChain()
    }

    convenience init?(attributes: Dictionary<String,AnyObject>, scope: String) {
        var aRefreshToken: String?
        var anAccessToken: String?
        aRefreshToken = attributes["refresh_token"] as? String
        anAccessToken = attributes["access_token"] as? String
        let expiresInSeconds = attributes["expires_in"] as? NSNumber
        self.init(refreshToken: aRefreshToken, accessToken: anAccessToken, scope: scope, expiresInSeconds:expiresInSeconds)
        storeInKeyChain()
    }

    class func isUserLoggedIn() -> Bool {
        let token = OAuthToken.oAuthTokenWithScope(kOauth2ScopeFull)
        if token == nil {
            return false
        }
        return true
    }

    func removeFromKeyChain() {
        if accessToken == nil {
            var existingTokens = OAuthToken.oAuthTokens()
            existingTokens[scope!] = nil
            LUKeychainAccess.standardKeychainAccess().setObject(existingTokens, forKey: kOAuth2TokensKey)
        }
    }

    func removeFromKeyChainIfNotValid() {
        if accessToken == nil && refreshToken == nil {
            removeFromKeyChain()
        }
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
            } else {
                return oAuthTokenWithScope(scope)
            }
        case 3:
            return oAuthTokenWithScope(scope)
        default:
            return oAuthTokenWithScope(scope)
        }
    }

    class func oAuthTokenWithScope(scope: String) -> OAuthToken? {
        let dictionary = LUKeychainAccess.standardKeychainAccess().objectForKey(kOAuth2TokensKey) as! NSDictionary?
        if let actualDictionary = dictionary as NSDictionary? {
            if let token = actualDictionary[scope] as?  OAuthToken? {
                return token
            }
        }
        return nil
    }

    class func oAuthTokens() -> Dictionary<String,AnyObject> {
        var tokenArray = Dictionary<String,AnyObject>()
        let dictionary = LUKeychainAccess.standardKeychainAccess().objectForKey(kOAuth2TokensKey) as! NSDictionary?
        if let actualDictionary = dictionary as NSDictionary? {
            for key in actualDictionary.allKeys as! [String] {
                let object: AnyObject = actualDictionary[key] as AnyObject!
                tokenArray[key] = object
            }
        }
        return tokenArray
    }

    class func oAuthScope(scope: String, isHigherThanOrEqualToScope otherScope: String) -> Bool {
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

    class func oAuthScopeForAuthenticationLevel(authenticationLevel: String) -> String {
        switch authenticationLevel {
        case AuthenticationLevel.password:
            return kOauth2ScopeFull
        case AuthenticationLevel.twoFactor:
            return kOauth2ScopeFullHighAuth
        case AuthenticationLevel.idPorten3:
            return kOauth2ScopeFull_Idporten3;
        case AuthenticationLevel.idPorten4:
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

    override var debugDescription: String {
        let accessTokenRepresentation : String = {
            if let token = self.accessToken as String? {
                return "HAS_TOKEN"
            } else {
                return "NO_TOKEN"
            }
            }()

        let refreshTokenRepresentation : String = {
            if let token = self.refreshToken as String? {
                return "HAS_TOKEN"
            } else {
                return "NO_TOKEN"
            }
            }()

        let dateFormatter = NSDateFormatter()
        let expirationDateRepresentation : String = {
            if let actualExpirationDate = self.expires {
                dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
                dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle
                return dateFormatter.stringFromDate(actualExpirationDate)
            } else {
                return "NO_DATE"
            }
            }()
        let dateTodayFormatted = dateFormatter.stringFromDate(NSDate())
        return "accessToken: \(accessTokenRepresentation), refreshToken: \(refreshTokenRepresentation), scope: \(scope), expires: \(expirationDateRepresentation) today: \(dateTodayFormatted)"
    }
}