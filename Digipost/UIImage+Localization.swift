//
//  UIImage+Localization.swift
//  Digipost
//
//  Created by Håkon Bogen on 25.09.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

import Foundation

extension UIImage {
    class func localizedImage(orientation: UIInterfaceOrientation) -> UIImage?{
        let locale = NSLocalizedString("language of app", comment: "the app language")
        var image: UIImage?
        if let localeName = locale as String? {
            if (UIInterfaceOrientationIsLandscape(orientation)){
                if (localeName.lowercaseString == "nb"){
                    image = UIImage(named: "Lastopp_veileder_norsk_horisontal")
                }else {
                    image = UIImage(named: "Lastopp_veileder_english_horisontal")
                }
            }else {
                if (localeName.lowercaseString == "nb"){
                    image = UIImage(named: "Lastopp_norsk_vertikal")
                } else {
                    image = UIImage(named: "Lastopp_engelsk_vertikal")
                }
            }
        }
        return image
    }
}