//
//  Recipient.swift
//  Digipost
//
//  Created by Hannes Waller on 2015-04-08.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import Foundation


class Recipient {
    let name: String
    let digipostAddress: String?
    let address: [AnyObject]?
    let mobileNumber: String?
    let organizationNumber: String?
    let uri: String?
    
    
    init?(recipient: [String : AnyObject]) {
        self.address = recipient[Constants.Recipient.address] as? [AnyObject]
        self.digipostAddress = recipient[Constants.Recipient.digipostAddress] as? String
        self.mobileNumber = recipient[Constants.Recipient.mobileNumber] as? String
        self.organizationNumber = recipient[Constants.Recipient.organizationNumber] as? String
        self.uri = recipient[Constants.Recipient.uri] as? String
        if let actualName = recipient[Constants.Recipient.name] as? String {
            self.name = actualName
        } else {
            self.name = ""
            return nil
        }
    }

    class func recipients(jsonDict jsonDict: [String : AnyObject]) -> [Recipient] {
        var recipients = [Recipient]()
        
        if let recipientArray = jsonDict[Constants.Recipient.recipient] as? [[String : AnyObject]] {
            for recipientDict in recipientArray {
                if let recipient = Recipient(recipient: recipientDict) {
                    recipients.append(recipient)
                }
            }
        }
        
        return recipients
    }
    
    func firstName() -> String {
        if self.organizationNumber != nil {
            return self.name
        } else {
            let name = self.name
            var nameArray = split(name) {$0 == " "}
            return nameArray[0]
        }
    }
}

