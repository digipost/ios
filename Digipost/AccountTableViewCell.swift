//
//  AccountTableViewCell.swift
//  Digipost
//
//  Created by Henrik Holmsen on 13.01.15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

class AccountTableViewCell: UITableViewCell {

    @IBOutlet weak var unreadMessages: UILabel!
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var accountImageView: UIImageView!
    @IBOutlet var initialLabel: UILabel!
    @IBOutlet weak var accountDescriptionLabel: UILabel!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Set account image to be circular
        
        accountImageView.layer.cornerRadius = accountImageView.frame.width / 2
        accountImageView.backgroundColor = UIColor.digipostProfileViewBackground()
        accountImageView.clipsToBounds = true
        accountNameLabel.textColor = UIColor.digipostProfileTextColor()

        initialLabel.textColor = UIColor.digipostProfileViewInitials()
        unreadMessages.textColor = UIColor.digipostProfileTextColor()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
