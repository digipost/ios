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

import UIKit
import LocalAuthentication

class SecureViewConroller: UIViewController {
    
    var context = LAContext()
    var blurEffectView: UIVisualEffectView = UIVisualEffectView(effect:  UIBlurEffect(style: .light))

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        blurOverlay()
        setupAuthenticationPolicy()
    }
    
    func blurOverlay() {
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(blurEffectView)
        } else {
            view.backgroundColor = .white
        }
    }
    
    func removeBlur() {
        DispatchQueue.main.async {
            self.blurEffectView.removeFromSuperview()
        }
    }
    
    func setupAuthenticationPolicy() {
        let policy: LAPolicy = .deviceOwnerAuthentication
        var error: NSError?
        guard context.canEvaluatePolicy(policy, error: &error) else {
            print("Error: canEvaluatePolicy \(String(describing: error))")
            return
        }
        
        accessRequest(policy: policy)
    }
    
    func dismissView(){
        print("dismissing")
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func accessRequest(policy: LAPolicy) {
        context.evaluatePolicy(policy, localizedReason: NSLocalizedString("settings access request", comment: "settings access request"), reply: { (success, error) in
            
            if(success) {
                self.removeBlur()
                print("Successfully logged in! 👍")
            }else{
                if let error = error {
                    switch(error) {
                    case LAError.touchIDLockout:
                        print("There were too many failed Touch ID attempts and Touch ID is now locked.")
                    case LAError.appCancel:
                        print("Authentication was canceled by application.")
                    case LAError.invalidContext:
                        print("LAContext passed to this call has been previously invalidated.")
                    default:
                        print("Touch ID may not be configured")
                    }
                } else{
                    print("Error: evaluatePolicy failed without error")
                }

                self.dismissView()
            }
        })
    }
}
