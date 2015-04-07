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
        if self.authenticationLevel == AuthenticationLevel.idPorten4 || self.authenticationLevel == AuthenticationLevel.idPorten3 || self.authenticationLevel == AuthenticationLevel.twoFactor {
            if authenticationLevel == nil {
                return false
            }
            let scopeForAttachment = OAuthToken.oAuthScopeForAuthenticationLevel(authenticationLevel)
            if scopeForAttachment == kOauth2ScopeFull {
                return false
            } else {
                let existingToken = OAuthToken.oAuthTokenWithScope(scopeForAttachment)
                if existingToken?.accessToken != nil {
                    return false
                }
                
                let highestToken = OAuthToken.highestScopeInStorageForScope(scopeForAttachment)
                
                if OAuthToken.oAuthScope(highestToken,isHigherThanOrEqualToScope:scopeForAttachment){
                    return false
                }
                return true
            }
        } else {
            return false
        }
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
