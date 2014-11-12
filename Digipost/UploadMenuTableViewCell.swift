//
//  UploadMenuTableViewCell.swift
//  Digipost
//
//  Created by Håkon Bogen on 03/11/14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

import UIKit

class UploadMenuTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
