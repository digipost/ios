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
    
    func needsAuthenticationToOpen(currentAuthenticationLevel: String) -> Bool{
        if currentAuthenticationLevel == kAuthenticationLevelIDPorten4 {
            return false
        } else if currentAuthenticationLevel == kAuthenticationLevelIDPorten3 {
            if authenticationLevel == kAuthenticationLevelIDPorten4 {
                return true
            } else if authenticationLevel == kAuthenticationLevelTwoFactor {
                return true
            }
            return false
        } else if currentAuthenticationLevel == kAuthenticationLevelTwoFactor {
            if authenticationLevel == kAuthenticationLevelIDPorten4 {
                return true
            } else if authenticationLevel == kAuthenticationLevelIDPorten3 {
                return true
            }
            return false
        }
        return true
    }
}
