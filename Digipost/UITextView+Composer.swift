//
//  UITextView+Composer.swift
//  Digipost
//
//  Created by Håkon Bogen on 06/05/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

extension UITextView {

    func style(#textAttribute: TextAttribute) {
        if let font = textAttribute.font {
            self.font = font
        }
        if let textAlignment = textAttribute.textAlignment {
            self.textAlignment = textAlignment
        }
    }
 
}
