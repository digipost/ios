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
                var storyboard:UIStoryboard!
                let userDefaults = NSUserDefaults.standardUserDefaults()
        
                let shouldViewNewFeatures = !userDefaults.boolForKey("hasViewedNewFeaturesForVersion")
        
                if shouldViewNewFeatures{
                    storyboard = UIStoryboard(name: "NewFeatures", bundle: nil)
                } else {
                    storyboard = UIStoryboard.storyboardForCurrentUserInterfaceIdiom()
                }
        
                // Store that user has viewed the onboarding
                let userdefaults = NSUserDefaults.standardUserDefaults()
                userDefaults.setBool(true, forKey: "hasViewedOnboarding")
                userDefaults.synchronize()
        
                let viewcontroller:UIViewController = storyboard.instantiateInitialViewController() as UIViewController
                self.presentViewController(viewcontroller, animated: false) { () -> Void in
                }
    }
    
    @IBAction func newUserButtonAction(sender: UIButton) {
    }
    
    @IBAction func privacyButtonAction(sender: UIButton) {
    }
    
}
