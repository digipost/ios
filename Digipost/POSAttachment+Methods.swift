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
        if authenticationLevel != nil {
            let scope = OAuthToken.oAuthScopeForAuthenticationLevel(authenticationLevel)
            if scope == kOauth2ScopeFull {
                return false
            } else {
                let existingScope = OAuthToken.oAuthTokenWithScope(scope)
                if existingScope?.accessToken != nil {
                    return false
                }
                return true
            }
        }
        return true
    }

    func originIsPublicEntity() -> Bool{
        if origin == nil {
            return false
        }

        if origin == "PUBLIC_ENTITY" {
            return true
        }
        return false
    }
}
