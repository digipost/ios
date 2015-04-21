//
//  RecipientViewController.swift
//  Digipost
//
//  Created by Henrik Holmsen on 08.04.15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

protocol RecipientsViewControllerDelegate {
    func addRecipients(recipients: [Recipient])
}

class RecipientViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!
    
    var delegate: RecipientsViewControllerDelegate? = nil
    
    var recipients : [Recipient] = [Recipient]()
    var addedRecipients : [Recipient] = [Recipient]()
    
    var recipientSearchController = UISearchController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("recipients view navigation bar title", comment: "")
        saveBarButtonItem.title = NSLocalizedString("recipients view navigation bar right button save", comment: "Title for bar button item")
                
        tableView.backgroundColor = UIColor(r: 222, g: 224, b: 225)
        tableView.registerNib(UINib(nibName: "RecipientTableViewCell", bundle: nil), forCellReuseIdentifier: "recipientCell")
        tableView.rowHeight = 70.0
        
        self.recipientSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.hidesNavigationBarDuringPresentation = false
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.searchBarStyle = .Minimal
            controller.searchBar.frame.size = self.navigationController!.navigationBar.frame.size
            controller.searchBar.backgroundColor = UIColor.whiteColor()
            controller.searchBar.delegate = self
            
            self.tableView.tableHeaderView = controller.searchBar

            return controller
        })()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        recipientSearchController.active = false
        recipientSearchController.searchBar.frame = CGRectMake(0, 0, 0, 0)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        recipientSearchController.searchBar.frame = self.navigationController!.navigationBar.frame
    }
// 
//    @IBAction func dismissViewController(sender: AnyObject) {
//        
//        let alertController = UIAlertController(title: "Brev lukkes", message: "Vil du lagre utkastet før du avslutter?", preferredStyle: UIAlertControllerStyle.Alert)
//        let saveDraftAction = UIAlertAction(title: "Lagre utkast",
//            style: UIAlertActionStyle.Default)
//            { [unowned self, alertController] (action: UIAlertAction!) -> Void in
//            println("Saved")
//                self.navigationController?.dismissViewControllerAnimated(true, completion: { () -> Void in
//                })
//        }
//        
//        let quitAction = UIAlertAction(title: "Lukk",
//            style: UIAlertActionStyle.Destructive)
//            { [unowned self, alertController] (action: UIAlertAction!) -> Void in
//                
//                self.navigationController?.dismissViewControllerAnimated(true, completion: { () -> Void in
//                })
//        }
//        
//        alertController.addAction(saveDraftAction)
//        alertController.addAction(quitAction)
//        
//        presentViewController(alertController, animated: true, completion: nil)
//    }
    
    @IBAction func returnToPreviewViewController() {
        if delegate != nil {
            delegate?.addRecipients(addedRecipients)
        }
        
        self.navigationController?.popViewControllerAnimated(true)
    }
}
