//
//  Authentication.swift
//  Digipost
//
//  Created by Fredrik Lillejordet on 23/04/2019.
//  Copyright © 2019 Posten Norge AS. All rights reserved.
//

import LocalAuthentication
import LUKeychainAccess

@objc class LAStore: NSObject {
    
    static let LA_STATE = "LocalAuthenticationState"
    static let LA_TIMESTAMP = "LocalAuthenticationTimestamp"
    
    @objc static func isAuthenticated() -> Bool {
        if let authenticated = UserDefaults.standard.object(forKey: LA_STATE) as? Bool {
            if let timestamp = UserDefaults.standard.object(forKey: LA_TIMESTAMP) as? String {
                let diff = Date().timeIntervalSince1970 - timestamp
                let tenMinutes = 60*10
                return authenticated && diff < tenMinutes
            }
        }
        return false
    }
    
    @objc static func saveAuthenticationState(authenticated: Bool) {
        UserDefaults.standard.set(authenticated, forKey: LA_STATE)
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: LA_TIMESTAMP)
        UserDefaults.standard.synchronize()
    }
}
