//
//  RecipientTableViewCell.swift
//  Digipost
//
//  Created by Hannes Waller on 2015-04-20.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

class RecipientTableViewCell: UITableViewCell {
    @IBOutlet weak var initialsViewImageView: UIImageView!
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
        
        addedButton.hidden = true
        initialsViewImageView.hidden = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func loadCell(recipient recipient: Recipient) {
        nameLabel.text = recipient.name
        addedButton.hidden = true
        
        initialsLabel.text = recipient.name.initials()
        initialsViewImageView.hidden = true
        addressLabel.text = generateAddressString(recipient)
        
        if recipient.organizationNumber != nil {
            initialsLabel.text = ""
            initialsViewImageView.hidden = false
            addressLabel.text = "Org.nr \(recipient.organizationNumber!)"
        }
    }
    
    
    func generateAddressString(recipient: Recipient) -> String {
        if let address : [AnyObject] = recipient.address {
            if address.count != 0 {
                if let street = address[0]["street"] as? String,
                    let houseNumber = address[0]["house-number"] as? String,
                    let houseLetter = address[0]["house-letter"] as? String,
                    let zipCode = address[0]["zip-code"] as? String,
                    let city = address[0]["city"] as? String {
                        return "\(street) \(houseNumber)\(houseLetter) \(zipCode) \(city)"
                }
            }
        }

        
        return recipient.digipostAddress!
    }
}
