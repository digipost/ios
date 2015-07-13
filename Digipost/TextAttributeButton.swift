//
//  TextAttributeButton.swift
//  Digipost
//
//  Created by Håkon Bogen on 06/05/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

class TextAttributeButton: UIButton {

    let textAttribute : TextAttribute

    init(textAttribute: TextAttribute, target: UIViewController, selector: Selector) {
        self.textAttribute = textAttribute
        super.init(frame: CGRectMake(0, 0, 55, 44))
        self.setTitle("Test", forState: .Normal)
        self.addTarget(target, action: selector, forControlEvents: .TouchUpInside)
    }

    required init(coder aDecoder: NSCoder) {
        self.textAttribute = TextAttribute()
        super.init(coder: aDecoder)
    }

    func indicateSelectedIfMatchingStyle(anotherTextAttribute : TextAttribute) {
        if self.textAttribute.hasOneOrMoreMatchesWith(textAttribute: anotherTextAttribute) {
            self.backgroundColor = UIColor.redColor()
        } else {
            self.backgroundColor = UIColor.whiteColor()
        }
    }

}
