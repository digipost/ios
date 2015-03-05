//
//  OnboardingLoginViewController.swift
//  Digipost
//
//  Created by Henrik Holmsen on 04.03.15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

class OnboardingLoginViewController: UIViewController {

    @IBOutlet var loginButton: UIButton!
    @IBOutlet var registerButton: UIButton!
    @IBOutlet var privacyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Localize button titels
        loginButton.setTitle(NSLocalizedString("LOGIN_VIEW_CONTROLLER_LOGIN_BUTTON_TITLE", comment: "Sign In"), forState: .Normal)
        registerButton.setTitle(NSLocalizedString("LOGIN_VIEW_CONTROLLER_REGISTER_BUTTON_TITLE", comment: "New user"), forState: .Normal)
        privacyButton.setTitle(NSLocalizedString("LOGIN_VIEW_CONTROLLER_PRIVACY_BUTOTN_TITLE", comment: "Privacy"), forState: .Normal)
        
    }

    @IBAction func loginButtonAction(sender: UIButton) {

        // Store that user has viewed the onboarding
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setBool(true, forKey: "hasViewedOnboarding")
        userDefaults.synchronize()
        let storyboard = UIStoryboard.storyboardForCurrentUserInterfaceIdiom()
        let viewcontroller:UIViewController = storyboard.instantiateInitialViewController() as UIViewController
        self.presentViewController(viewcontroller, animated: false, completion: nil)
    }
    
    @IBAction func registerButtonAction(sender: UIButton) {
        if let newUserURL = NSURL(string: "https://www.digipost.no/app/registrering#/") {
           presentActionSheetFromSenderWithURL(sender, url: newUserURL)
        }
    }
    
    @IBAction func privacyButtonAction(sender: UIButton) {
        if let privacyURL = NSURL(string: "https://www.digipost.no/juridisk/#personvern") {
            presentActionSheetFromSenderWithURL(sender, url: privacyURL)
        }
    }
    
    func presentActionSheetFromSenderWithURL(sender: UIButton, url: NSURL){
        UIActionSheet.showFromRect(sender.frame,
            inView: sender.superview,
            animated: true,
            withTitle: url.host,
            cancelButtonTitle: NSLocalizedString("GENERIC_CANCEL_BUTTON_TITLE", comment: "Cancel"),
            destructiveButtonTitle: nil,
            otherButtonTitles: [NSLocalizedString("GENERIC_OPEN_IN_SAFARI_BUTTON_TITLE", comment: "Open in Safari")]
            ) { (actionSheet: UIActionSheet!, buttonIndex: Int) -> Void in
                if buttonIndex == 0 {
                    UIApplication.sharedApplication().openURL(url)
                }
        }
    }
}
