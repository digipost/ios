//
// Copyright (C) Posten Norge AS
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

extension POSRootResource {
    
    @objc func getContactInfo() -> POSContactInfo? {
        let extendedEmail = getExtendedEmail()
        let extendedPhone = getPhoneNumber()
        return POSContactInfo(extendedEmail: extendedEmail, extendedPhone: extendedPhone)
    }
    
    @objc func getExtendedEmail() -> [POSEmail] {
        var extendedEmail = [POSEmail]()
        if let extendedEmailData = NSKeyedUnarchiver.unarchiveObject(with: self.extendedEmail) as? NSArray {
            for json in extendedEmailData as! [[String: Any]] {
                if let email = json["email"] as? String, let verified = json["verified"] as? Bool {
                    extendedEmail.append(POSEmail(email: email, verified: verified))
                }
            }
        }
        return extendedEmail
    }
    
    @objc func getPhoneNumber() -> POSPhone {
        if let extendedPhoneData = NSKeyedUnarchiver.unarchiveObject(with: self.extendedPhone) as? [String: Any] {
            if let phoneNumber = extendedPhoneData["phoneNumber"] as? String, let countryCode = extendedPhoneData["countryCode"] as? String {
                return POSPhone(phoneNumber: phoneNumber, countryCode: countryCode)
            }
        }
        return POSPhone(phoneNumber: "", countryCode: "")
    }
}
