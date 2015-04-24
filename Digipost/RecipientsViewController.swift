//
//  RecipientViewController.swift
//  Digipost
//
//  Created by Henrik Holmsen on 08.04.15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit
import SingleLineKeyboardResize

class RecipientViewController: UIViewController, UINavigationControllerDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var recipients : [Recipient] = [Recipient]()
    var addedRecipients : [Recipient] = [Recipient]()

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
    
    override func viewWillDisappear(animated: Bool) {
        removeKeyboardNotificationListeners()
    }
    
    override func viewDidDisappear(animated: Bool) {

    }

    @IBAction func handleSingleTapOnEmptyTableView(tap: UIGestureRecognizer) {
        let point = tap.locationInView(tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(point)
        
        if indexPath == nil {
            searchBar.resignFirstResponder()
        }
    }

    @IBAction func didTapSaveBarButtonItem() {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
