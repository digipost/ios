//
//  PreviewViewController.swift
//  Digipost
//
//  Created by Henrik Holmsen on 08.04.15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController, RecipientsViewControllerDelegate {
    
    var recipients = [Recipient]()
    var modules = [ComposerModule]()

    @IBOutlet weak var recipientsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var addRecipientsButton: UIButton!


    // the selected digipost address for the mailbox that should show as sender when sending current compsing letter
    var mailboxDigipostAddress : String?

    var currentShowingHTMLContent : String?


    override func viewDidLoad() {
        super.viewDidLoad()
        
        ComposerModuleParser.parseComposerModuleContentToHTML(modules, response: { [unowned self] (htmlString) -> ()  in
            self.webView.loadHTMLString(htmlString, baseURL: nil)
            self.currentShowingHTMLContent = htmlString!
        })
        
//        tableView.registerNib(UINib(nibName: "RecipientTableViewCell", bundle: nil), forCellReuseIdentifier: "recipientCell")
//        tableView.rowHeight = 70.0
//        
//        let footerView = NSBundle.mainBundle().loadNibNamed("AddRecipientTableFooterView", owner: self, options: nil)[0] as! UIView
//        footerView.frame = CGRectMake(0, 0, view.frame.width, 80.0)
//        footerView.backgroundColor = UIColor.clearColor()
//    
//        var goToAddRecipientsTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "didTapFooterView:")
//        goToAddRecipientsTap.cancelsTouchesInView = false
//        footerView.addGestureRecognizer(goToAddRecipientsTap)
//        
//        tableView.tableFooterView = footerView
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func didTapFooterView(sender: AnyObject) {
        performSegueWithIdentifier("addRecipientsSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let recipientsViewController = segue.destinationViewController as? RecipientViewController {
            recipientsViewController.recipientDelegate = self
            if recipients.count > 0 {
                recipientsViewController.addedRecipients = recipients
            }
        }
    }
    
    func addRecipients(addedRecipients: [Recipient]) {
        self.recipients = addedRecipients
        tableView.reloadData()
    }
    
    @IBAction func didTapSendButton(sender: AnyObject) {

        let mailbox = POSMailbox.existingMailboxWithDigipostAddress(mailboxDigipostAddress, inManagedObjectContext: POSModelManager.sharedManager().managedObjectContext)

        APIClient.sharedClient.send(currentShowingHTMLContent!, recipients: recipients, uri: mailbox.sendUri, success: { () -> Void in
            self.dismissViewControllerAnimated(true, completion: { () -> Void in

            })

            }) { (error) -> () in
                println(error)
        }
    }

}
