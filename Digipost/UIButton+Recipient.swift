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
            let localizedEnding = String.localizedStringWithFormat(NSLocalizedString("recipients add more button overflow text", comment: "the end of recipients string when it overflows its size"), remainingStrings)
            let localizedMorePersons = remainingStrings == 0 ? "" : localizedEnding
            let allPersonsWithMorePersonsString = "\(string)\(localizedMorePersons)"
            self.setTitle(allPersonsWithMorePersonsString, forState: .Normal)
            let sizeFits = self.sizeThatFits(currentSize)
            if sizeFits.width > currentSize.width {
                if lastFittedString == "" {
                    self.setTitle(allPersonsWithMorePersonsString, forState: .Normal)
                    break
                } else {
                    self.setTitle(lastFittedString, forState: .Normal)
                }
            } else {
                lastFittedString = allPersonsWithMorePersonsString
            }
        }
    }
 
}
