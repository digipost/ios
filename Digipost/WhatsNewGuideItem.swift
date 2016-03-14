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
            debugIfNil(image, message: "could not find image named \(WhatsNewGuideItem.nameForIndex(index)) index:\(index)")
            debugIfNil(image, message: "could not find localized string \(WhatsNewGuideItem.guideItemNameForIndexWithoutUserInterfaceIdiom(index)) in table \(GuideConstants.whatsNewTableName) index: \(index)")
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
