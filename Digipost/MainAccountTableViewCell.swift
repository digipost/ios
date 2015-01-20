//
//  MainAccountTableViewCell.swift
//  Digipost
//
//  Created by Hannes Waller on 2015-01-15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

class MainAccountTableViewCell: UITableViewCell {

    @IBOutlet weak var accountImageView: UIImageView!
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var initialLabel: UILabel!
    @IBOutlet weak var unreadMessages: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        accountImageView.backgroundColor = UIColor.digipostProfileViewBackground()
        accountImageView.layer.cornerRadius = accountImageView.frame.width / 2
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
