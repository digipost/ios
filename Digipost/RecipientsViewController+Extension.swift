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
        var cell = self.tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
        cell.accessoryType = UITableViewCellAccessoryType.None
        cell.textLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 14)
        cell.selectionStyle = UITableViewCellSelectionStyle.None

        if recipientSearchController.active {
            if count(recipients) >= 0 {
                if let recipient = recipients[indexPath.row].name {
                    cell.textLabel?.text = recipient
                    for r in addedRecipients {
                        if r.name == recipient && r.digipostAddress == recipients[indexPath.row].digipostAddress {
                            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                        }
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
        var found = false

        if recipientSearchController.active {
            for (index, r) in enumerate(addedRecipients) {
                if r.name == recipients[indexPath.row].name {
                    tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.None
                    addedRecipients.removeAtIndex(index)
                    tableView.reloadData()
                    found = true
                }
            }
            if found == false { addedRecipients.append(recipients[indexPath.row]) }
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if recipientSearchController.active == false {
            addedRecipients.removeAtIndex(indexPath.row)
        }
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        var footerView = UIView(frame: CGRectZero)
        
        var singleTap = UITapGestureRecognizer(target: self, action: "handleSingleTapOnEmptyTableView:")
        singleTap.numberOfTapsRequired = 1
        singleTap.cancelsTouchesInView = false
        tableView.addGestureRecognizer(singleTap)
        
        return footerView
    }
    
    @IBAction func handleSingleTapOnEmptyTableView(tap: UIGestureRecognizer) {
        let point = tap.locationInView(tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(point)

        if indexPath == nil {
            recipientSearchController.active = false
        }
    }
    
}

extension RecipientViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        recipients.removeAll(keepCapacity: false)
        
        if recipientSearchController.searchBar.text == "" {
            tableView.reloadData()
        } else if recipientSearchController.searchBar.text != "" {
            APIClient.sharedClient.getRecipients(recipientSearchController.searchBar.text, success: { (responseDictionary) -> Void in
                self.recipients = Recipient.recipients(jsonDict: responseDictionary)
                
                }) { (error) -> () in
                    println(error)
            }
        }
    }
}

extension RecipientViewController: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        UIView.animateWithDuration(0.3,
            animations: { () -> Void in
                searchBar.backgroundColor = UIColor(r: 227, g: 45, b: 34)
                searchBar.tintColor = UIColor.whiteColor()
        })
        return true
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        UIView.animateWithDuration(0.3,
            animations: { () -> Void in
                searchBar.backgroundColor = UIColor.whiteColor()
        })
    }

}

