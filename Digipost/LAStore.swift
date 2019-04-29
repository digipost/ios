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
    
    @objc static func isValidAuthenticationAndTimestamp() -> Bool {
        return authenticationIsValid() && timestampIsValid()
    }
    
    @objc static func authenticationIsValid() -> Bool {
        if let authenticated = UserDefaults.standard.object(forKey: LA_STATE) as? Bool {
            return authenticated
        }
        return false
    }
    
    @objc static func timestampIsValid() -> Bool {
        if let timestamp = UserDefaults.standard.object(forKey: LA_TIMESTAMP) as? Double {
            let diff = Date().timeIntervalSince1970 - timestamp
            let timeLimit = 20
            return Int(diff) < timeLimit
        }
        return false
    }
    
    @objc static func deleteAuthenticationAndTimestamp() {
        UserDefaults.standard.removeObject(forKey: LA_STATE)
        UserDefaults.standard.removeObject(forKey: LA_TIMESTAMP)
        UserDefaults.standard.synchronize()
    }
    
    @objc static func saveAuthenticationState(authenticated: Bool) {
        UserDefaults.standard.set(authenticated, forKey: LA_STATE)
        UserDefaults.standard.synchronize()
    }
    
    @objc static func saveAuthenticationTimeout(timestamp: TimeInterval) {
        UserDefaults.standard.set(timestamp,forKey: LA_TIMESTAMP)
        UserDefaults.standard.synchronize()
    }
    
    @objc static func authenticateUser(completion: @escaping (_ success: Bool, _ error: String) -> Void){
        let policy: LAPolicy = .deviceOwnerAuthentication
        var error: NSError?
        let context = LAContext()
        guard context.canEvaluatePolicy(policy, error: &error) else {
            completion(false, "Error: canEvaluatePolicy \(String(describing: error))")
            return
        }
        
        context.evaluatePolicy(policy, localizedReason: NSLocalizedString("localauthentication_request", comment: "localauthentication_request"), reply: { (success, error) in
            if(success) {
                LAStore.saveAuthenticationState(authenticated: true)
                completion(true, "")
            }else{
                var errorText = "Error: evaluatePolicy failed without error";
                if let error = error {
                    switch(error) {
                    case LAError.touchIDLockout:
                        errorText = "There were too many failed Touch ID attempts and Touch ID is now locked."
                    case LAError.appCancel:
                        errorText = "Authentication was canceled by application."
                    case LAError.invalidContext:
                        errorText = "LAContext passed to this call has been previously invalidated."
                    default:
                        errorText = "Touch ID may not be configured"
                    }
                }
                LAStore.saveAuthenticationState(authenticated: false)
                completion(false, errorText)
            }
        })
    }
}
