//
//  RecipientViewController.swift
//  Digipost
//
//  Created by Henrik Holmsen on 08.04.15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

class RecipientViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var recipients : [Recipient] = [Recipient]() {
        didSet { tableView.reloadData() }
    }
    var addedRecipients : [Recipient] = [Recipient]() {
        didSet { tableView.reloadData() }
    }
    
    var recipientSearchController = UISearchController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor(r: 222, g: 224, b: 225)
        
        self.recipientSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.hidesNavigationBarDuringPresentation = true
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.searchBarStyle = .Minimal
            controller.searchBar.frame.size = self.navigationController!.navigationBar.frame.size
            controller.searchBar.backgroundColor = UIColor.whiteColor()
            controller.searchBar.delegate = self
            
            self.tableView.tableHeaderView = controller.searchBar

            return controller
        })()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goToComposer" {
            if let navController = segue.destinationViewController as? UINavigationController,
                let composerController = navController.viewControllers.first as? ComposerViewController {
                    composerController.recipients = addedRecipients
            }
        }
    }
    
    @IBAction func dismissViewController(sender: AnyObject) {
        
        let alertController = UIAlertController(title: "Brev lukkes", message: "Vil du lagre utkastet før du avslutter?", preferredStyle: UIAlertControllerStyle.Alert)
        let saveDraftAction = UIAlertAction(title: "Lagre utkast",
            style: UIAlertActionStyle.Default)
            { [unowned self, alertController] (action: UIAlertAction!) -> Void in
            println("Saved")
                self.navigationController?.dismissViewControllerAnimated(true, completion: { () -> Void in
                })
        }
        
        let quitAction = UIAlertAction(title: "Lukk",
            style: UIAlertActionStyle.Destructive)
            { [unowned self, alertController] (action: UIAlertAction!) -> Void in
                
                self.navigationController?.dismissViewControllerAnimated(true, completion: { () -> Void in
                })
        }
        
        alertController.addAction(saveDraftAction)
        alertController.addAction(quitAction)
        
        presentViewController(alertController, animated: true, completion: nil)
        
        
    }
}
