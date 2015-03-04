//
//  Guide.swift
//  Digipost
//
//  Created by Håkon Bogen on 04/03/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import Foundation


private struct GuideConstants {
    private static let shortVersionString : NSObject = "CFBundleShortVersionString"
    private static let whatsNewTableName = "WhatsNewGuideTexts"
}

class Guide {
    
    private class var hasShownWhatsNewGuideForCurrentVersion : Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(versionStringWithDashesInsteadOfPeriods)
    }
    
    private class var versionStringWithDashesInsteadOfPeriods : String  {
        let versionString : AnyObject = NSBundle.mainBundle().infoDictionary![GuideConstants.shortVersionString]!
        let versionStringWithDashesInsteadOfPeriods = versionString.stringByReplacingOccurrencesOfString(".", withString: "-")
        return versionStringWithDashesInsteadOfPeriods
    }
    
    /**
    Checks if you have both image and text for a given feature in this version of the app, then checks if the user has seen the whats new guide for this version.
    If both image and text are present, and user has not seen the whats new guide, it returns true, else false
    
    :returns: whether to show the whats new guide to user
    */
    class func shouldShowWhatsNewGuide() -> Bool {
        
        // String format for images, for example iPhone: "2-5-0_1-iphone"
        
        let firstObjectForThisVersionString = "\(versionStringWithDashesInsteadOfPeriods)_1"
        switch UIDevice.currentDevice().userInterfaceIdiom {
        case .Pad:
            if let firstImage = UIImage(named: "\(firstObjectForThisVersionString)-ipad") {
                if let firstText = NSLocalizedString(firstObjectForThisVersionString,tableName:GuideConstants.whatsNewTableName, comment:"") as String? {
                    if hasShownWhatsNewGuideForCurrentVersion == false {
                        return true
                    }
                }
            }
            break
        case .Phone:
            if let firstImage = UIImage(named: "\(firstObjectForThisVersionString)-iphone") {
                if let firstText = NSLocalizedString(firstObjectForThisVersionString,tableName:GuideConstants.whatsNewTableName, comment:"") as String? {
                    if hasShownWhatsNewGuideForCurrentVersion == false {
                        return true
                    }
                }
            }
            break
        default:
            return false
        }
        
        return false
    }
    
    class func whatsNewGuideItems() {
        
    }
    
    class func shouldShowOnboardingGuide() -> Bool {
        return true
    }
    
}