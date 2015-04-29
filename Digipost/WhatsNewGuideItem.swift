//
//  WhatsNewGuideItem.swift
//  Digipost
//
//  Created by Håkon Bogen on 04/03/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

class WhatsNewGuideItem {
    let image : UIImage!
    let text : String!
    
    init(image: UIImage, text:String) {
        self.image = image
        self.text = text
    }
    
    convenience init?(index: Int) {
        let image = UIImage(named:WhatsNewGuideItem.nameForIndex(index))
        let text =  LocalizedString(WhatsNewGuideItem.guideItemNameForIndexWithoutUserInterfaceIdiom(index),tableName:GuideConstants.whatsNewTableName, comment:"") as String?
        
        if image == nil || text == nil {
            debugIfNil(image, "could not find image named \(WhatsNewGuideItem.nameForIndex(index)) index:\(index)")
            debugIfNil(image, "could not find localized string \(WhatsNewGuideItem.guideItemNameForIndexWithoutUserInterfaceIdiom(index)) in table \(GuideConstants.whatsNewTableName) index: \(index)")
            self.init(image:UIImage(),text:"")
            return nil
        } else {
            self.init(image:image!,text:text!)
        }
    }
    
    class func nameForIndex(index: Int) -> String {
        var languageString = ""
        switch UIDevice.currentDevice().userInterfaceIdiom {
        case .Pad:
            languageString = NSLocalizedString("language", tableName: GuideConstants.whatsNewTableName, comment: "language for image")
            return "\(languageString)-\(guideItemNameForIndexWithoutUserInterfaceIdiom(index))-ipad"
        case .Phone:
            languageString = NSLocalizedString("language", tableName: GuideConstants.whatsNewTableName, comment: "language for image")
            return "\(languageString)-\(guideItemNameForIndexWithoutUserInterfaceIdiom(index))-iphone"
        default:
            languageString = NSLocalizedString("language", tableName: GuideConstants.whatsNewTableName, comment: "language for image")
            return "\(languageString)-\(guideItemNameForIndexWithoutUserInterfaceIdiom(index))-iphone"
        }
    }
    
    class func guideItemNameForIndexWithoutUserInterfaceIdiom(index: Int) -> String {
        return "\(Guide.versionStringWithDashesInsteadOfPeriods)_\(index)"
    }
}
