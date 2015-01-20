//
//  UIColor+DigipostColors.swift
//  Digipost
//
//  Created by Håkon Bogen on 24/10/14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    
    class func digipostSpaceGrey () -> UIColor {
        return UIColor(r: 64, g: 66, b: 69)
    }
    
    class func digipostGreyOne () -> UIColor {
        return UIColor(r: 239, g: 66, b: 69)
    }
    
    class func digipostProfileViewBackground () -> UIColor {
        return UIColor(r: 232, g: 232, b: 232)
    }
    
    class func digipostProfileViewInitials () -> UIColor {
        return UIColor(r: 141, g: 141, b: 141)
    }
    
    class func digipostProfileTextColor () -> UIColor {
        return UIColor(r: 77, g: 79, b: 83)
    }
    
    class func digipostAccountViewBackground () -> UIColor {
        return UIColor(r: 248, g: 248, b: 248)
    }
    
}
