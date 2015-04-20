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
        
    }
    
}
