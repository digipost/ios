//
//  UIStoryboard+deviceSpesificStoryboard.swift
//  Digipost
//
//  Created by Henrik Holmsen on 03.03.15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import Foundation

extension UIStoryboard {
    class func storyboardForCurrentUserInterfaceIdiom() -> UIStoryboard {
        let device = UIDevice.currentDevice().userInterfaceIdiom
        switch device {
        case .Phone:
            return UIStoryboard(name: "Main_iPhone", bundle: nil) 
        case .Pad:
            return UIStoryboard(name: "Main_iPad", bundle: nil)
        case .Unspecified:
            return UIStoryboard(name: "Main_iPhone", bundle: nil)
        default:
            return UIStoryboard(name: "Main_iPhone", bundle: nil)
        }
    }
}