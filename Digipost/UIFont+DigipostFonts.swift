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
    class func digipostRegularFont() -> UIFont{
        let regularFont = UIFont(name: "FoundryMonoline-Regular", size: 20)
        return regularFont
    }
    class func digipostMediumFontSizeMedium() -> UIFont{
        let regularFont = UIFont(name: "FoundryMonoline-Medium", size: 18)
        return regularFont
    }
    class func digipostMediumFontSizeSmall() -> UIFont{
        let regularFont = UIFont(name: "FoundryMonoline-Medium", size: 17)
        return regularFont
    }
    class func debugToFindNameOfCustomFonts(){
        let familyNamesArray : NSArray = UIFont.familyNames()
        familyNamesArray.enumerateObjectsUsingBlock { (object , index, stop) -> Void in
            let familyName = object as NSString
            let names : NSArray = UIFont.fontNamesForFamilyName(familyName)
            println(object)
            names.enumerateObjectsUsingBlock({ (obj , i, stop) -> Void in
                println(obj)
            })
            
            }
            
        }
}