//
// Copyright (C) Posten Norge AS
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//         http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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

    class func recipients(jsonDict: [String : AnyObject]) -> [Recipient] {
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
            var nameArray = name.components(separatedBy: " ")
            return nameArray[0]
        }
    }
}

