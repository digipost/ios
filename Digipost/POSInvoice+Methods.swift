//
//  POSInvoice+Methods.swift
//  Digipost
//
//  Created by Håkon Bogen on 28/10/14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

import UIKit

extension POSInvoice {
    
    func titleForInvoiceButtonLabel(isSending: Bool) -> String {
        var title : String? = nil
        if isSending {
            title = NSLocalizedString("LETTER_VIEW_CONTROLLER_INVOICE_BUTTON_SENDING_TITLE", comment:"Sending...");
        } else if let actualTimePaid = timePaid as NSDate? {
            title = NSLocalizedString("LETTER_VIEW_CONTROLLER_INVOICE_BUTTON_PAID_TITLE", comment:"Sent to bank");
        } else if let paidByUser = canBePaidByUser.boolValue as Bool?  {
            
            if let bankURI = sendToBankUri as NSString? {
                title = NSLocalizedString("LETTER_VIEW_CONTROLLER_INVOICE_BUTTON_SEND_TITLE", comment:"Send to bank");
            } else {
                title = NSLocalizedString("LETTER_VIEW_CONTROLLER_INVOICE_BUTTON_PAYMENT_TIPS_TITLE", comment:"Payment tips");
            }
        }else {
            title = NSLocalizedString("LETTER_VIEW_CONTROLLER_INVOICE_BUTTON_PAYMENT_TIPS_TITLE", comment:"Payment tips");
        }
        return title!
    }
}
