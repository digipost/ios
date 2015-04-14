//
//  ComposerViewController+TableViewDelegate.swift
//  Digipost
//
//  Created by Håkon Bogen on 10/04/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

extension ComposerViewController {

    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 44
    }


    func height(forTextInCellTextView text: String) -> CGFloat {
        if let textView = exampleTextView() {
            textViewWidth = notesTextView!.frame.size.width
            textView = notesTextView!
        } else {

        }
    }
}
