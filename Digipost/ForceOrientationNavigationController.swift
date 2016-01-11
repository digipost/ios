//
//  ForceOrientationNavigationController.swift
//  Digipost
//
//  Created by Hannes Waller on 2015-03-11.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

class ForceOrientationNavigationController: UINavigationController {
    let device = UIDevice.currentDevice().userInterfaceIdiom

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
    
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        let device = UIDevice.currentDevice().userInterfaceIdiom
        
        switch device {
        case .Phone:
            return UIInterfaceOrientationMask.Portrait
        case .Pad:
            return UIInterfaceOrientationMask.Landscape
        default:
            return UIInterfaceOrientationMask.Portrait
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
