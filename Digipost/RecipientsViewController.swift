//
//  RecipientViewController.swift
//  Digipost
//
//  Created by Henrik Holmsen on 08.04.15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit
import SingleLineKeyboardResize

protocol RecipientsViewControllerDelegate {
    func addRecipients(recipients: [Recipient])
}

class RecipientViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var recipientDelegate: RecipientsViewControllerDelegate?

    var recipients : [Recipient] = [Recipient]()
    var addedRecipients : [Recipient] = [Recipient]()
    
    var recipientSearchController : UISearchController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("recipients view navigation bar title", comment: "")
        saveBarButtonItem.title = NSLocalizedString("recipients view navigation bar right button save", comment: "Title for bar button item")
                
        tableView.backgroundColor = UIColor(r: 222, g: 224, b: 225)
        tableView.registerNib(UINib(nibName: "RecipientTableViewCell", bundle: nil), forCellReuseIdentifier: "recipientCell")
        tableView.rowHeight = 65.0
        
        searchBar.delegate = self
        searchBar.placeholder = NSLocalizedString("recipients view search bar placeholder", comment: "placeholder text")
        searchBar.returnKeyType = UIReturnKeyType.Done
        
        setupKeyboardNotifcationListenerForScrollView(self.tableView)
    }

    @IBAction func handleSingleTapOnEmptyTableView(tap: UIGestureRecognizer) {
        let point = tap.locationInView(tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(point)
        
        if indexPath == nil {
            searchBar.resignFirstResponder()
        }
    }

    @IBAction func didTapSaveBarButtonItem() {
        recipientDelegate?.addRecipients(addedRecipients)

        self.navigationController?.popViewControllerAnimated(true)
    }
}
