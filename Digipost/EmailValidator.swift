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

class EmailValidator {
    static func emailAppearsValid(email: String) -> Bool {
        let commonDomains = ["gmail.com", "hotmail.com","online.no","live.no", "yahoo.no", "hotmail.no", "outlook.com","yahoo.com", "lyse.net", "icloud.com", "getmail.no", "me.com"]
        
        let splittedEmail = email.split(separator: "@")
        let domainName = splittedEmail[0].lowercased()
        
        for blacklisted in ["digipost.no", "digipost.com", "example.com", "gmai.com"] {
            if domainName == blacklisted {
                return false
            }
        }
        
        return true
    }
}
