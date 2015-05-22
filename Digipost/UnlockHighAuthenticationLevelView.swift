//
//  UnlockHighAuthenticationLevelView.swift
//  Digipost
//
//  Created by Håkon Bogen on 28/11/14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

import UIKit

class UnlockHighAuthenticationLevelView: UIView {

    @IBOutlet weak var unlockButton: UIButton!
    @IBOutlet weak var unlockLabel: UILabel!

    func setup(canBeUnlocked: Bool) {
        if canBeUnlocked {
            unlockLabel.text = NSLocalizedString("unlock view label can unlock letter",  comment: "")
            unlockButton.hidden = false
        } else {
            unlockLabel.text = NSLocalizedString("unlock view label can not unlock letter",  comment: "")
            unlockButton.hidden = true
        }
    }
}
