//
//  RecipientsViewController+UISearchBarDelegate.swift
//  Digipost
//
//  Created by Hannes Waller on 2015-04-15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

extension RecipientViewController: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        
        return true
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        tableView.reloadData()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        recipients.removeAll(keepCapacity: false)
        
        if searchBar.text == "" {
            tableView.reloadData()
        } else if searchBar.text != "" {
            APIClient.sharedClient.getRecipients(searchBar.text, success: { (responseDictionary) -> Void in
                self.recipients = Recipient.recipients(jsonDict: responseDictionary)
                self.tableView.reloadData()
                }) { (error) -> () in
                    println(error)
            }
        }

    }
}
