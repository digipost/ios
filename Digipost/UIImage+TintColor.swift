//
//  UIImage+TintColor.swift
//  Digipost
//
//  Created by Håkon Bogen on 06/11/14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

import UIKit

extension UIImage {
    
    class func templateImage(named: String) -> UIImage {
        let image = UIImage(named: named)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        return image!
    }
}
