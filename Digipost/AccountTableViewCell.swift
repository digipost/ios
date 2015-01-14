//
//  AccountTableViewCell.swift
//  Digipost
//
//  Created by Henrik Holmsen on 13.01.15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

class AccountTableViewCell: UITableViewCell {

    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var accountImageView: UIImageView!
    @IBOutlet var initialLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Set defaul image background
        self.accountImageView.backgroundColor = UIColor.lightGrayColor()
        // Set account image to be circular
        let imageWidth = accountImageView.frame.width
        let cornerRadius = imageWidth/2
        self.accountImageView.layer.cornerRadius = cornerRadius
        self.accountImageView.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
