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
    func onboardingLoginViewControllerDidTapLoginButtonWithBackgroundImage(onboardingLoginViewController: OnboardingLoginViewController, backgroundImage: UIImage)
}

class OnboardingLoginViewController: UIViewController {

    @IBOutlet var loginButton: UIButton!
    @IBOutlet var registerButton: UIButton!
    @IBOutlet var privacyButton: UIButton!
    
    weak var delegate : OnboardingLoginViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Localize button titels
        loginButton.setTitle(NSLocalizedString("LOGIN_VIEW_CONTROLLER_LOGIN_BUTTON_TITLE", comment: "Sign In"), forState: .Normal)
        registerButton.setTitle(NSLocalizedString("LOGIN_VIEW_CONTROLLER_REGISTER_BUTTON_TITLE", comment: "New user"), forState: .Normal)
        privacyButton.setTitle(NSLocalizedString("LOGIN_VIEW_CONTROLLER_PRIVACY_BUTTON_TITLE", comment: "Privacy"), forState: .Normal)
        
        
        
    }

    @IBAction func loginButtonAction(sender: UIButton) {
        // Store that user has viewed the onboarding

        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.frame.origin.x -= self.view.frame.width
        }) { (Bool) -> Void in
            Guide.setOnboaringHasBeenWatched()
            if let del = self.delegate {
              del.onboardingLoginViewControllerDidTapLoginButtonWithBackgroundImage(self, backgroundImage: self.onboardingBackgroundSnapShot())
            }
        }
    }
    
    func onboardingBackgroundSnapShot() -> UIImage!{
        var backgroundSnapShot:UIImage!
        if let onboardingViewController = self.parentViewController{
            let backgroundSize = onboardingViewController.view.layer.bounds.size
            UIGraphicsBeginImageContextWithOptions(backgroundSize, true, 0)
            onboardingViewController.view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
            backgroundSnapShot = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        return backgroundSnapShot
    }
    
    @IBAction func registerButtonAction(sender: UIButton) {
        if let newUserURL = NSURL(string: "https://www.digipost.no/app/registrering?utm_source=iOS_app&utm_medium=app&utm_campaign=app-link&utm_content=ny_bruker#/") {
            UIApplication.sharedApplication().openURL(newUserURL);    
        }
    }

    @IBAction func privacyButtonAction(sender: UIButton) {
        if let newUserURL = NSURL(string: "https://www.digipost.no/juridisk/#personvern") {
            UIApplication.sharedApplication().openURL(newUserURL);    
        }
    }
    
    func openURL(url: NSURL){
        let url = NSURL(string: "https://google.com")!
        UIApplication.sharedApplication().openURL(url)
    }
    
    func presentAlertFromSenderWithUrl(sender: UIButton, url: NSURL){
        let alert = UIAlertController(title: url.host, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("GENERIC_OPEN_IN_SAFARI_BUTTON_TITLE", comment: "Open in Safari"), style: .Default,handler: {(alert: UIAlertAction!) in
            UIApplication.sharedApplication().openURL(url)
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("GENERIC_CANCEL_BUTTON_TITLE", comment: "Cancel"), style: UIAlertActionStyle.Cancel, handler: {(alert: UIAlertAction!) in }))
        
        presentViewController(alert, animated: true, completion: nil)
    }
}
