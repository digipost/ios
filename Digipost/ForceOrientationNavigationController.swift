//
//  ForceOrientationNavigationController.swift
//  Digipost
//
//  Created by Hannes Waller on 2015-03-11.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

class ForceOrientationNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        var orientation: Int?
        let device = UIDevice.currentDevice().userInterfaceIdiom
        switch device {
        case .Phone:
            if self.visibleViewController.isKindOfClass(NewFeaturesViewController) {
                orientation = UIInterfaceOrientation.Portrait.rawValue
            }
        case .Pad:
            orientation = UIInterfaceOrientation.LandscapeLeft.rawValue
        default: break
        }
        UIDevice.currentDevice().setValue(orientation, forKey: "orientation")
    }
    
    override func shouldAutorotate() -> Bool {
        if self.visibleViewController.isKindOfClass(NewFeaturesViewController) {
            return false
        }
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return self.topViewController.supportedInterfaceOrientations()
    }

    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        if self.visibleViewController.isKindOfClass(NewFeaturesViewController) {
            return UIInterfaceOrientation.Portrait
        } else {
            return self.viewControllers.last!.preferredInterfaceOrientationForPresentation()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
