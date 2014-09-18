//
//  SHCAppDelegate+Appearance.swift
//  Digipost
//
//  Created by Håkon Bogen on 18.09.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

import Foundation
import UIKit

extension SHCAppDelegate {
    class func setupAppearance() {
        SHCAppDelegate.setupNavBarAppearance()
    }
    
    class func setupNavBarAppearance() {
        UINavigationBar.appearance().barStyle = .Black
        UINavigationBar.appearance().barTintColor = UIColor(red: 227/255, green: 45/255, blue: 34/255, alpha: 1)
        UINavigationBar.appearance().tintColor = UIColor(white: 1, alpha: 0.8)
        UINavigationBar.appearance().titleTextAttributes =  [ NSForegroundColorAttributeName : UIColor.whiteColor()]
    }
}