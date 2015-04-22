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
                if let recipient = recipients[indexPath.row] as Recipient? {
                    cell.loadCell(recipient: recipient)
                    for r in addedRecipients {
                        if r.name! == recipient.name && r.digipostAddress! == recipients[indexPath.row].digipostAddress! {
                            cell.addedButton.hidden = false
                        }
                    }
                }
            }
        } else {
            if let recipient = addedRecipients[indexPath.row] as Recipient? {
                cell.loadCell(recipient: recipient)
                cell.addedButton.hidden = false
            }
        }
        
        return cell
    }
}

