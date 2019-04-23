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

import LocalAuthentication
import LUKeychainAccess

@objc class LAStore: NSObject {
    
    static let LA_STATE = "LocalAuthenticationState"
    static let LA_TIMESTAMP = "LocalAuthenticationTimestamp"
    
    @objc static func isAuthenticated() -> Bool {
        if let authenticated = UserDefaults.standard.object(forKey: LA_STATE) as? Bool {
            if let timestamp = UserDefaults.standard.object(forKey: LA_TIMESTAMP) as? String {
                let diff = Date().timeIntervalSince1970 - timestamp
                let tenMinutes = 600
                return authenticated && diff < tenMinutes
            }
        }
        return false
    }
    
    @objc static func saveAuthenticationState(authenticated: Bool) {
        UserDefaults.standard.set(authenticated, forKey: LA_STATE)
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: LA_TIMESTAMP)
        UserDefaults.standard.synchronize()
    }
}
