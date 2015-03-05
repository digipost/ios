//
//  Guide.swift
//  Digipost
//
//  Created by Håkon Bogen on 04/03/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import Foundation

struct GuideConstants {
    private static let shortVersionString : NSObject = "CFBundleShortVersionString"
    private static let hasShownOnboardingKey = "hasShownOnboardingKey"
    static let whatsNewTableName = "WhatsNewGuideTexts"
    static let onboardingTableName = "OnboardingGuideTexts"
}

class Guide {
    
    private class var hasShownWhatsNewGuideForCurrentVersion : Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(versionStringWithDashesInsteadOfPeriods)
    }
    
    private class var hasShownOnboarding : Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(GuideConstants.hasShownOnboardingKey)
    }
    
    class var versionStringWithDashesInsteadOfPeriods : String  {
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
        
        if let firstImage = UIImage(named: WhatsNewGuideItem.nameForIndex(1)) {
            if let firstText = NSLocalizedString(WhatsNewGuideItem.guideItemNameForIndexWithoutUserInterfaceIdiom(1),tableName:GuideConstants.whatsNewTableName, comment:"") as String? {
                if hasShownWhatsNewGuideForCurrentVersion == false {
                    return true
                }
            }
        }
        return false
    }
    
    /**
    checks if app has not shown onboarding guide before, and that there are at least one localized text to show
    
    :returns: whether to show onboarding guide or not
    */
    class func shouldShowOnboardingGuide() -> Bool {
        if onboardingText(forIndex: 1) != nil {
            return hasShownOnboarding == false
        }
        return false
    }
    
    class func whatsNewGuideItems() -> [WhatsNewGuideItem] {
        var index = 1 // designers don't start counting on zero.
        var guideItems = [WhatsNewGuideItem]()
        while let whatsNewItem = WhatsNewGuideItem(index: index) {
            guideItems.append(whatsNewItem)
            index++
        }
        return guideItems
    }
    
    class func onboardingText(#forIndex: Int) -> String? {
        return NSLocalizedString("onboarding_\(index)",tableName:GuideConstants.onboardingTableName, comment:"") as String?
    }

    class func setWhatsNewFeaturesHasBeenWatchedForThisVersion() {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: versionStringWithDashesInsteadOfPeriods)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func setOnboaringHasBeenWatched() {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: GuideConstants.hasShownOnboardingKey)
    }
}