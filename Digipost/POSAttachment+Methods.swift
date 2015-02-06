//
//  POSAttachment+Methods.swift
//  Digipost
//
//  Created by Håkon Bogen on 28/10/14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

import UIKit

extension POSAttachment {
    
    func hasValidToPayInvoice() -> Bool {
        if let actualInvoice = invoice as POSInvoice? {
            if actualInvoice.canBePaidByUser.boolValue {
                return true
            }
        }
        return false
    }
    
    func needsAuthenticationToOpen() -> Bool{
        if  self.uri == nil {
            if authenticationLevel == nil {
                return false
            }
            let scope = OAuthToken.oAuthScopeForAuthenticationLevel(authenticationLevel)
            if scope == kOauth2ScopeFull {
                return false
            } else {
                let existingScope = OAuthToken.oAuthTokenWithScope(scope)
                println(existingScope)
                println(scope)
                if existingScope?.accessToken != nil {
                    return false
                }
                return true
            }
        } else {
            return false
        }
    }
}
