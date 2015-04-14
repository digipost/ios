//
//  UIFont+DigipostFonts.swift
//  Digipost
//
//  Created by Håkon Bogen on 18.09.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
    class func digipostRegularFont() -> UIFont {
        let regularFont = UIFont.systemFontOfSize(17)
        return regularFont
    }
    
    class func digipostBoldFont() -> UIFont? {
        let boldFont = UIFont(name: "HelveticaNeue-Bold", size: 17)
        return boldFont!
    }
    // debug method used when you are looking for custom font names
    class func debugToFindNameOfCustomFonts(){
        let familyNamesArray : NSArray = UIFont.familyNames()
        familyNamesArray.enumerateObjectsUsingBlock { (object , index, stop) -> Void in
            let familyName = object as! NSString
            let names : NSArray = UIFont.fontNamesForFamilyName(familyName as String)
            names.enumerateObjectsUsingBlock({ (obj , i, stop) -> Void in
                println(obj)
            })
        }
    }
}
