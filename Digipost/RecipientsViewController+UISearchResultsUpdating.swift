//
//  RecipientsViewController+SearchResultsUpdatingExtension.swift
//  Digipost
//
//  Created by Hannes Waller on 2015-04-15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

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