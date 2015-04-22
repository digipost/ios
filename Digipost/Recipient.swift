//
//  Recipient.swift
//  Digipost
//
//  Created by Hannes Waller on 2015-04-08.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import Foundation

private struct RecipientConstants {
    static let name: String = "name"
}

class Recipient {
    let name: String?
    let digipostAddress: String?
    let address: [AnyObject]?
    let mobileNumber: String?
    let organizationNumber: String?
    let uri: String?
    
    
    init?(recipient: [String : AnyObject]) {
        if let name = recipient["name"] as? String {
            self.name = name
        }
        else {
            self.name = ""
            self.address = [AnyObject]()
            self.digipostAddress = ""
            self.mobileNumber = ""
            self.organizationNumber = ""
            self.uri = ""
            return nil
        }
        self.address = recipient["address"] as? [AnyObject]
        self.digipostAddress = recipient["digipost-address"] as? String
        self.mobileNumber = recipient["mobile-number"] as? String
        self.organizationNumber = recipient["organisation-number"] as? String
        self.uri = recipient["uri"] as? String
    }

    class func recipients(#jsonDict: [String : AnyObject]) -> [Recipient] {
        var recipients = [Recipient]()
        
        if let recipientArray = jsonDict["recipient"] as? [[String : AnyObject]] {
            for recipientDict in recipientArray {
                if let recipient = Recipient(recipient: recipientDict) {
                    recipients.append(recipient)
                }
            }
        }
        
        return recipients
    }
    
}

