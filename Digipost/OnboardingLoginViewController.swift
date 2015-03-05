//
//  OnboardingLoginViewController.swift
//  Digipost
//
//  Created by Henrik Holmsen on 04.03.15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

class OnboardingLoginViewController: UIViewController {

    @IBAction func loginButtonAction(sender: UIButton) {

        // Store that user has viewed the onboarding
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setBool(true, forKey: "hasViewedOnboarding")
        userDefaults.synchronize()
        let storyboard = UIStoryboard.storyboardForCurrentUserInterfaceIdiom()
        let viewcontroller:UIViewController = storyboard.instantiateInitialViewController() as UIViewController
        self.presentViewController(viewcontroller, animated: false, completion: nil)
    }
    
    @IBAction func newUserButtonAction(sender: UIButton) {
    }
    
    @IBAction func privacyButtonAction(sender: UIButton) {
    }
    
}
