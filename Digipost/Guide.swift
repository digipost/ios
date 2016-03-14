//
// Copyright (C) Posten Norge AS
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//         http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

struct GuideConstants {
    private static let shortVersionString : NSObject = "CFBundleShortVersionString"
    private static let hasShownOnboardingKey = "hasShownOnboardingKey"
    static let whatsNewTableName = "WhatsNewGuideTexts"
    static let onboardingTableName = "OnboardingGuideTexts"
}

class Guide : NSObject {
    
    private class var hasShownWhatsNewGuideForCurrentVersion : Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(versionStringWithDashesInsteadOfPeriods)
    }
    
    private class var hasShownOnboarding : Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(GuideConstants.hasShownOnboardingKey)
    }
    
    class var versionStringWithDashesInsteadOfPeriods : String  {
        let versionString : AnyObject = NSBundle.mainBundle().infoDictionary![GuideConstants.shortVersionString as! String]!
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
        if OAuthToken.isUserLoggedIn(){
            return false
        }
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
    /**
    
    :param: forIndex index of the localized text
    
    :returns: the text as index, else nil
    */
    class func onboardingText(forIndex forIndex: Int) -> String? {
        let string = LocalizedString("onboarding_\(forIndex)", tableName: GuideConstants.onboardingTableName, comment: "")
        debugIfNil(string, message: " could not get a localized string for index: \(forIndex) in table: \(GuideConstants.onboardingTableName)")
        return string
    }

    class func setWhatsNewFeaturesHasBeenWatchedForThisVersion() {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: versionStringWithDashesInsteadOfPeriods)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func setOnboaringHasBeenWatched() {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: GuideConstants.hasShownOnboardingKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}