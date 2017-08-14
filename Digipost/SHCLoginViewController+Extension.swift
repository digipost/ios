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

public extension SHCLoginViewController {
    
    public func setupAuthenticationPolicy() {
        let context = LAContext()
        let policy: LAPolicy = .deviceOwnerAuthentication
        var error: NSError?
        guard context.canEvaluatePolicy(policy, error: &error) else {
            print("Error: canEvaluatePolicy \(String(describing: error))")
            return
        }
        login(context: context, policy: policy)
    }
    
    public func login(context: LAContext, policy: LAPolicy){
        context.evaluatePolicy(policy, localizedReason: "Trengs for å bruke Touch ID som innlogging", reply: { (success, error) in
            
            guard success else {
                guard let error = error else {
                    self.touchIDResult(false)
                    return
                }
                
                switch(error) {
                case LAError.touchIDLockout:
                    print("There were too many failed Touch ID attempts and Touch ID is now locked.")
                    self.touchIDResult(false)
                case LAError.appCancel:
                    print("Authentication was canceled by application.")
                    self.touchIDResult(false)
                case LAError.invalidContext:
                    print("LAContext passed to this call has been previously invalidated.")
                    self.touchIDResult(false)
                default:
                    print("Touch ID may not be configured")
                    self.touchIDResult(false)
                }
                return
            }
            
            // Success
            DispatchQueue.main.async {
                print("Successfully logged in! 👍")
                self.touchIDResult(true)
                return
            }
        })
    }
}
