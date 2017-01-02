//
// Copyright (C) Posten Norge AS
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//         http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
        
        addedButton.isHidden = true
        initialsViewImageView.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func loadCell(recipient: Recipient) {
        nameLabel.text = recipient.name
        addedButton.isHidden = true
        
        initialsLabel.text = recipient.name.initials()
        initialsViewImageView.isHidden = true
        addressLabel.text = generateAddressString(recipient)
        
        if recipient.organizationNumber != nil {
            initialsLabel.text = ""
            initialsViewImageView.isHidden = false
            addressLabel.text = "Org.nr \(recipient.organizationNumber!)"
        }
    }
    
    
    func generateAddressString(_ recipient: Recipient) -> String {
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
