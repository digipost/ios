//
//  RecipientsViewController+Extension.swift
//  Digipost
//
//  Created by Hannes Waller on 2015-04-09.
//  Copyright (c) 2015 Posten. All rights reserved.
//

extension RecipientViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchBar.isFirstResponder() {
            return self.recipients.count
        } else {
            return self.addedRecipients.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = self.tableView.dequeueReusableCellWithIdentifier("recipientCell") as! RecipientTableViewCell
        
        if searchBar.isFirstResponder() {
            if count(recipients) > 0 {
                if let recipient = recipients[indexPath.row].name {
                    cell.nameLabel.text = recipient
                    cell.addedButton.hidden = true
                    
                    cell.initialsLabel.text = recipient.initials()
                    cell.initialsViewImageView.hidden = true
                    cell.addressLabel.text = generateAddressString(recipients[indexPath.row].address!, recipient: recipients[indexPath.row])
                    
                    if recipients[indexPath.row].organizationNumber != nil {
                        cell.initialsLabel.text = ""
                        cell.initialsViewImageView.hidden = false
                        cell.addressLabel.text = recipients[indexPath.row].organizationNumber!
                    }
                    
                    for r in addedRecipients {
                        if r.name == recipient && r.digipostAddress == recipients[indexPath.row].digipostAddress {
                            cell.addedButton.hidden = false
                        }
                    }
                }
            }
        } else {
            if let recipient = addedRecipients[indexPath.row].name {
                cell.nameLabel.text = recipient
                cell.initialsLabel.text = recipient.initials()
                cell.addedButton.hidden = false
            }
        }
        
        return cell
    }
  
    func generateAddressString(address: [AnyObject], recipient: Recipient) -> String {
        if address.count != 0 {
            if let street = address[0]["street"] as? String,
            let houseNumber = address[0]["house-number"] as? String,
            let houseLetter = address[0]["house-letter"] as? String,
            let zipCode = address[0]["zip-code"] as? String,
                let city = address[0]["city"] as? String {
                    return "\(street) \(houseNumber)\(houseLetter) \(zipCode) \(city)"
            }
        }
        
        return recipient.digipostAddress!
    }
}

