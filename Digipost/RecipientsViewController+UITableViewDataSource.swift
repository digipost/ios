//
//  RecipientsViewController+Extension.swift
//  Digipost
//
//  Created by Hannes Waller on 2015-04-09.
//  Copyright (c) 2015 Posten. All rights reserved.
//

extension RecipientViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.recipientSearchController.active {
            return self.recipients.count
        } else {
            return self.addedRecipients.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = self.tableView.dequeueReusableCellWithIdentifier("recipientCell") as! RecipientTableViewCell
        
        let name = recipients[indexPath.row].name
        let address = recipients[indexPath.row].address
        
        println(address)
    
        cell.initialsLabel.text = name?.initials()
        cell.nameLabel.text = name
        //cell.addressLabel.text = address
        
        if recipientSearchController.active {
            if count(recipients) >= 0 {
                if let recipient = recipients[indexPath.row].name {
                    for r in addedRecipients {
                        if r.name == recipient && r.digipostAddress == recipients[indexPath.row].digipostAddress {
                            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                        }
                    }
                }
            }
            
        } else {
            if let recipient = addedRecipients[indexPath.row].name {
                
            }
        }
        
        return cell
    }
    
}

