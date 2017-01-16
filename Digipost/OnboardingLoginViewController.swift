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

@objc
protocol OnboardingLoginViewControllerDelegate {
    func onboardingLoginViewControllerDidTapLoginButtonWithBackgroundImage(_ onboardingLoginViewController: OnboardingLoginViewController, backgroundImage: UIImage)
}

class OnboardingLoginViewController: UIViewController {

    @IBOutlet var loginButton: UIButton!
    @IBOutlet var registerButton: UIButton!
    @IBOutlet var privacyButton: UIButton!
    
    weak var delegate : OnboardingLoginViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Localize button titels
        loginButton.setTitle(NSLocalizedString("LOGIN_VIEW_CONTROLLER_LOGIN_BUTTON_TITLE", comment: "Sign In"), for: UIControlState())
        registerButton.setTitle(NSLocalizedString("LOGIN_VIEW_CONTROLLER_REGISTER_BUTTON_TITLE", comment: "New user"), for: UIControlState())
        privacyButton.setTitle(NSLocalizedString("LOGIN_VIEW_CONTROLLER_PRIVACY_BUTTON_TITLE", comment: "Privacy"), for: UIControlState())
        
        
        
    }

    @IBAction func loginButtonAction(_ sender: UIButton) {
        // Store that user has viewed the onboarding

        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.view.frame.origin.x -= self.view.frame.width
        }, completion: { (Bool) -> Void in
            Guide.setOnboaringHasBeenWatched()
            if let del = self.delegate {
              del.onboardingLoginViewControllerDidTapLoginButtonWithBackgroundImage(self, backgroundImage: self.onboardingBackgroundSnapShot())
            }
        }) 
    }
    
    func onboardingBackgroundSnapShot() -> UIImage!{
        var backgroundSnapShot:UIImage!
        if let onboardingViewController = self.parent{
            let backgroundSize = onboardingViewController.view.layer.bounds.size
            UIGraphicsBeginImageContextWithOptions(backgroundSize, true, 0)
            onboardingViewController.view.layer.render(in: UIGraphicsGetCurrentContext()!)
            backgroundSnapShot = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        return backgroundSnapShot
    }
    
    @IBAction func registerButtonAction(_ sender: UIButton) {   
            openExternalUrl(url: "https://www.digipost.no/app/registrering?utm_source=iOS_app&utm_medium=app&utm_campaign=app-link&utm_content=ny_bruker#/")
    }

    @IBAction func privacyButtonAction(_ sender: UIButton) {
        openExternalUrl(url: "https://www.digipost.no/juridisk/#personvern")
    }
    
    func openExternalUrl(url: String){
        if #available(iOS 9.0, *) {
            let svc = SFSafariViewController(url: NSURL(string: url) as! URL)
            self.present(svc, animated: true, completion: nil)
        }
    }
    
    func presentAlertFromSenderWithUrl(_ sender: UIButton, url: URL){
        let alert = UIAlertController(title: url.host, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("GENERIC_OPEN_IN_SAFARI_BUTTON_TITLE", comment: "Open in Safari"), style: .default,handler: {(alert: UIAlertAction!) in
            self.openExternalUrl(url: url.absoluteString)
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("GENERIC_CANCEL_BUTTON_TITLE", comment: "Cancel"), style: UIAlertActionStyle.cancel, handler: {(alert: UIAlertAction!) in }))
        
        present(alert, animated: true, completion: nil)
    }
}
