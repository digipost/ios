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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc func updateContactInfo(contactInfo: POSContactInfo) {
        DispatchQueue.main.async {
            if let emails = contactInfo.extendedEmail {
                for (index, email) in emails.enumerated() {
                    switch(index) {
                    case 0:
                        self.email1?.text = email.email
                    case 1:
                        self.email2?.text = email.email
                    case 2:
                        self.email3?.text = email.email
                    default:
                        return
                    }
                }
            }
            
            if let number = contactInfo.extendedPhone?.phoneNumber {
                self.phonenumber?.text = number
            }
            
            if let code = contactInfo.extendedPhone?.countryCode {
                self.countryCode?.text = code
            }
        }
    }
    
    @IBAction func changedValue(_ sender: UITextField) {
    }
    
}
