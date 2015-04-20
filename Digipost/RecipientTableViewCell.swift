//
//  RecipientTableViewCell.swift
//  Digipost
//
//  Created by Hannes Waller on 2015-04-20.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

class RecipientTableViewCell: UITableViewCell {
    @IBOutlet weak var initialsLabel: UILabel!
    @IBOutlet weak var initialsView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var addedButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()

        initialsView.layer.cornerRadius = initialsView.frame.size.width / 2
        initialsView.clipsToBounds = true
        
        addedButton.layer.cornerRadius = addedButton.frame.size.width / 2
        addedButton.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func loadCell(name: String, address: String) {
        initialsLabel.text = name.initials()
        nameLabel.text = name
        addressLabel.text = address
        addedButton.hidden = true
    }

}
