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
    
    @objc static func isValidAuthentication() -> Bool {
        return authenticationIsValid()
    }
    
    @objc static func authenticationIsValid() -> Bool {
        if let authenticated = UserDefaults.standard.object(forKey: LA_STATE) as? Bool {
            return authenticated
        }
        return false
    }

    @objc static func deleteAuthentication() {
        UserDefaults.standard.removeObject(forKey: LA_STATE)
        UserDefaults.standard.synchronize()
    }
    
    @objc static func saveSuccessfullAuthentication(){
        LAStore.saveAuthenticationState(authenticated: true)
    }
    
    @objc static func saveAuthenticationState(authenticated: Bool) {
        UserDefaults.standard.set(authenticated, forKey: LA_STATE)
        UserDefaults.standard.synchronize()
    }
        
    @objc static func devicePasscodeMinimumSet() -> Bool {
        return LAContext().canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
    }
    
    @objc static func authenticateUser(completion: @escaping (_ success: Bool, _ errorText: String, _ userCancel: Bool) -> Void){
        let policy: LAPolicy = .deviceOwnerAuthentication
        let context = LAContext()
        
        context.evaluatePolicy(policy, localizedReason: NSLocalizedString("localauthentication_request", comment: "localauthentication_request"), reply: { (success, error) in
            if(success) {
                LAStore.saveSuccessfullAuthentication()
                completion(true, "", false)
            }else{
                var userCancel = false
                var errorText = "Error: evaluatePolicy failed without error"
                if let error = error {
                    switch(error) {
                    case LAError.touchIDLockout:
                        errorText = "There were too many failed Touch ID attempts and Touch ID is now locked."
                    case LAError.appCancel:
                        errorText = "Authentication was canceled by application."
                    case LAError.userCancel:
                        errorText = "The user tapped the cancel button in the authentication dialog."
                        userCancel = true
                    case LAError.invalidContext:
                        errorText = "LAContext passed to this call has been previously invalidated."
                    case LAError.passcodeNotSet:
                        errorText = "Passcode not set"
                    default:
                        errorText = "Touch ID may not be configured"
                    }
                }
                LAStore.saveAuthenticationState(authenticated: false)
                completion(false, errorText, userCancel)
            }
        })
    }
}
