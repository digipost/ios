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
    
    override func supportedInterfaceOrientations() -> Int {
        let device = UIDevice.currentDevice().userInterfaceIdiom
        
        switch device {
        case .Phone:
            return Int(UIInterfaceOrientationMask.Portrait.rawValue)
        case .Pad:
            return Int(UIInterfaceOrientationMask.Landscape.rawValue)
        default:
            return Int(UIInterfaceOrientationMask.Portrait.rawValue)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
