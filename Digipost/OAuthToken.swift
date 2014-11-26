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
    var refreshToken: String?
    var accessToken: String?
    var scope: String?
    
    required convenience init(coder decoder: NSCoder) {
        self.init()
        self.refreshToken = decoder.decodeObjectForKey(Keys.refreshTokenKey) as String?
        self.accessToken = decoder.decodeObjectForKey(Keys.accessTokenKey) as String?
        self.scope = decoder.decodeObjectForKey(Keys.scopeKey) as String?
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.refreshToken, forKey: Keys.refreshTokenKey)
        coder.encodeObject(self.accessToken, forKey: Keys.accessTokenKey)
        coder.encodeObject(self.scope, forKey: Keys.scopeKey)
    }
    
    convenience init?(refreshToken: String?, accessToken: String?, scope:String) {
        self.init()
        
        if let acutalRefreshToken = refreshToken as String? {
            self.refreshToken = acutalRefreshToken
        } else {
            return nil
        }
        if let actualAccessToken = accessToken as String? {
            self.accessToken = actualAccessToken
        }else {
            return nil
        }
        self.scope = scope
    }
    
    convenience init?(attributes: Dictionary<String,AnyObject>, scope: String) {
        var aRefreshToken: String!
        var anAccessToken: String?
        
        aRefreshToken = attributes["refresh_token"] as String?
        anAccessToken = attributes["access_token"] as String?
        self.init(refreshToken: aRefreshToken, accessToken: anAccessToken, scope: scope)
    }
}