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
        if let contactInfoData = NSKeyedUnarchiver.unarchiveObject(with: self.contactInfo) as! [Any]? {
            let extendedEmail = getExtendedEmail(extendedEmailData: contactInfoData[0] as! [Any])
            let extendedPhone = getPhoneNumber(extendedPhoneData: contactInfoData[1] as! [String: Any])
            return POSContactInfo(extendedEmail: extendedEmail, extendedPhone: extendedPhone)
        }

        return nil
    }
    
    func getExtendedEmail(extendedEmailData: [Any]) -> [POSEmail] {
        var extendedEmail = [POSEmail]()
        for json in extendedEmailData as! [[String: Any]] {
            if let email = json["email"] as? String, let verified = json["verified"] as? Bool {
                extendedEmail.append(POSEmail(email: email, verified: verified))
            }
        }
        return extendedEmail
    }
    
    func getPhoneNumber(extendedPhoneData: [String: Any]) -> POSPhone {
        if let phoneNumber = extendedPhoneData["phoneNumber"] as? String, let countryCode = extendedPhoneData["countryCode"] as? String {
            return POSPhone(phoneNumber: phoneNumber, countryCode: countryCode)
        }
        return POSPhone(phoneNumber: "", countryCode: "")
    }
}
