//
//  UIButton+Recipient.swift
//  Digipost
//
//  Created by Håkon Bogen on 23/04/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

private struct RecipientButtonExtensionConstants {
    static let widthMargin : CGFloat = 80
}

extension UIButton {

    func fitAsManyStringsAsPossible(strings: [String]) {
        if strings.count == 0 {
            return
        }
        self.setTitle("", forState: UIControlState.Normal)
        let containerView = self.superview
        let currentSize = CGSizeMake(self.frame.size.width - RecipientButtonExtensionConstants.widthMargin, self.frame.size.height)
        var string = strings[0]
        var lastFittedString = ""
        for i in 0..<strings.count {
            let remainingStrings = (strings.count - i) - 1
            if i != 0 {
                string = string.stringByAppendingString(", \(strings[i])")
            }
            let localizedMorePersons = remainingStrings == 0 ? "" : " og \(remainingStrings) fler"
            let allPersonsWithMorePersonsString = "\(string)\(localizedMorePersons)"
            self.setTitle(allPersonsWithMorePersonsString, forState: .Normal)
            let sizeFits = self.sizeThatFits(currentSize)
            println()
            if sizeFits.width > currentSize.width {
                self.setTitle(lastFittedString, forState: .Normal)
            } else {
                lastFittedString = allPersonsWithMorePersonsString
            }
        }
    }
 
}
