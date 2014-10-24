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
    
}
