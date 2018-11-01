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

class ContactViewController: UIViewController {
    
    @IBOutlet weak var email1: UITextField!
    @IBOutlet weak var email2: UITextField!
    @IBOutlet weak var email3: UITextField!
    @IBOutlet weak var countryCode: UITextField!
    @IBOutlet weak var phonenumber: UITextField!
    
    var mailboxSettings: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
    var emails: [[String: Any]] = [[String: Any]]()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        getMailboxSettings()
    }
    
    @objc func updateView(mailboxSettings: Dictionary<String, AnyObject>) {
        self.mailboxSettings = mailboxSettings
        self.emails = mailboxSettings["emailAddress"] as! [[String: Any]]
        
        DispatchQueue.main.async {
            for (index, email) in self.emails.enumerated() {
                switch(index) {
                case 0:
                    self.email1?.text =  email["email"] as? String
                case 1:
                    self.email2?.text =  email["email"] as? String
                case 2:
                    self.email3?.text =  email["email"] as? String
                default:
                    return
                }
            }
            
            if let mobilePhoneNumber = mailboxSettings["mobilePhoneNumber"] {
                self.phonenumber?.text = mobilePhoneNumber["phoneNumber"] as? String
                self.countryCode?.text = mobilePhoneNumber["countryCode"] as? String
            }
        }
    }
    
    func updateEmail(index: Int, emailAddress: String) {
        var email = emails[index]
        email["email"] = emailAddress
        emails[index] = email
        postMailboxSettings()
    }
    
    @IBAction func changedValue(_ sender: UITextField) {
        if sender == email1 {
            updateEmail(index: 0, emailAddress: email1.text!)
        }else if sender == email2 {
            updateEmail(index: 1, emailAddress: email2.text!)
        } else if sender == email3 {
            updateEmail(index: 2, emailAddress: email3.text!)
        }
    }
    
    func getMailboxSettings() {
        if let rootResource: POSRootResource =
            POSRootResource.existingRootResource(in: POSModelManager.shared().managedObjectContext) {
            if let mailboxSettingsUri = rootResource.mailboxSettingsUri {
                APIClient.sharedClient.getMailboxSettings(uri: mailboxSettingsUri, success: {(mailboxSettings) -> Void in
                    self.updateView(mailboxSettings: mailboxSettings)
                }, failure: ({_ in }))
            }
        }
    }
    
    func postMailboxSettings() {
        var mailboxSettings = self.mailboxSettings
        mailboxSettings.updateValue(self.emails as AnyObject, forKey: "emailAddress")
        
        if let rootResource: POSRootResource =
            POSRootResource.existingRootResource(in: POSModelManager.shared().managedObjectContext) {
            if let mailboxSettingsUri = rootResource.mailboxSettingsUri {
                APIClient.sharedClient.updateMailboxSettings(uri: mailboxSettingsUri,mailboxSettings: mailboxSettings as! Dictionary<String, AnyObject>,success: {() -> Void in
                    self.getMailboxSettings()
                }, failure: ({_ in }))
            }
        }
    }
    
}
