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

class SettingsValidator {
    
    static func emailAppearsValid(email: String) -> Bool {
        
        let commonDomains = ["gmail.com", "hotmail.com","online.no","live.no", "yahoo.no", "hotmail.no", "outlook.com","yahoo.com", "lyse.net", "icloud.com", "getmail.no", "me.com"]
        
        
        return notBlacklistedDomain(email: email) && validEmailPattern(email: email)
    }
    
    static func notBlacklistedDomain(email: String) -> Bool {
        let splittedEmail = email.split(separator: "@")
        if splittedEmail.count > 1 {
            let domainName = splittedEmail[1]
            for blacklisted in ["digipost.no", "digipost.com", "example.com", "gmai.com", "gmail.co"] {
                if domainName.lowercased().elementsEqual(blacklisted) {
                    return false
                }
            }
        }
        return true
    }
    
    static func validEmailPattern(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
}
