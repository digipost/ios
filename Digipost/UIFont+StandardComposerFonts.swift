//
//  UIFont+StandardComposerFonts.swift
//  Digipost
//
//  Created by Håkon Bogen on 02/07/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

extension UIFont {
    
    class func headlineH1() -> UIFont {
        return UIFont.boldSystemFontOfSize(22)
    }

    class func headlineH2() -> UIFont {
        return UIFont.boldSystemFontOfSize(20)
    }

    class func headlineH3() -> UIFont {
        return UIFont.boldSystemFontOfSize(18)
    }

    class func paragraph() -> UIFont {
        return UIFont.systemFontOfSize(15)
    }

}

