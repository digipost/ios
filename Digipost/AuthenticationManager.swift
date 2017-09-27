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
import LocalAuthentication

@objc class AuthenticationManager: NSObject {
    
    static let sharedInstance = AuthenticationManager()
    var needsAuthentication = false
    let laContext = LAContext()
    let laPolicy: LAPolicy = .deviceOwnerAuthentication
    
    public func touchIDCallback(result: Bool) {
        
    }
    
    public func canUseAuthentication() -> Bool {
        var error: NSError?
        guard laContext.canEvaluatePolicy(laPolicy, error: &error) else {
            return false
        }
        return true
    }
    
    public func evaluateAuthentication(){
        laContext.evaluatePolicy(laPolicy, localizedReason: "Trengs for å bruke Touch ID som innlogging", reply: { (success, error) in
            guard success else {
                guard let error = error else {
                    self.touchIDCallback(result: false)
                    return
                }
                
                switch(error) {
                case LAError.touchIDLockout:
                    print("There were too many failed Touch ID attempts and Touch ID is now locked.")
                    self.touchIDCallback(result: false)
                    
                case LAError.appCancel:
                    print("Authentication was canceled by application.")
                    self.touchIDCallback(result: false)
                case LAError.invalidContext:
                    print("LAContext passed to this call has been previously invalidated.")
                    self.touchIDCallback(result: false)
                default:
                    print("Touch ID may not be configured")
                    self.touchIDCallback(result: false)
                }
                return
            }
            
            DispatchQueue.main.async {
                print("Successfully logged in! 👍")
                self.touchIDCallback(result: true)
                return
            }
        })
    }
}
