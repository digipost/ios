//
//  RecipientsViewController+Extension.swift
//  Digipost
//
//  Created by Hannes Waller on 2015-04-09.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import Foundation
import UIKit

extension RecipientViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.recipientSearchController.active {
            return self.recipients.count
        } else {
            return self.addedRecipients.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
        cell.accessoryType = UITableViewCellAccessoryType.None
        cell.textLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 14)

        if recipientSearchController.active {
            if let recipient = recipients[indexPath.row].name {
                cell.textLabel?.text = recipient

                for r in addedRecipients {
                    if r.name == recipient && r.digipostAddress == recipients[indexPath.row].digipostAddress {
                        cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                    }
                }
            }
        } else {
            if let recipient = addedRecipients[indexPath.row].name {
                cell.textLabel?.text = recipient
            }
        }
        
        return cell
    }
}

extension RecipientViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if recipientSearchController.active {
            addedRecipients.append(recipients[indexPath.row])
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            tableView.reloadData()
        } else {
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
        }
    }
}

extension RecipientViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        recipients.removeAll(keepCapacity: false)
        
        if recipientSearchController.searchBar.text == "" {
            tableView.reloadData()
        }
        
        APIClient.sharedClient.getRecipients(recipientSearchController.searchBar.text, success: { (responseDictionary) -> Void in
            self.recipients = Recipient.recipients(jsonDict: responseDictionary)
            self.tableView.reloadData()
            
            }) { (error) -> () in
                println(error)
        }
    }
}

extension RecipientViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if recipientSearchController.active == false {
            addedRecipients.removeAtIndex(indexPath.row)
            tableView.reloadData()
        }
    }
}
