//
//  PreviewViewController.swift
//  Digipost
//
//  Created by Henrik Holmsen on 08.04.15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {
    
    var recipients = [Recipient]()
    var modules = [ComposerModule]()

    @IBOutlet weak var recipientsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ComposerModuleParser.parseComposerModuleContentToHTML(modules, response: { [unowned self] (htmlString) -> ()  in
            self.webView.loadHTMLString(htmlString, baseURL: nil)
        })
        
        let footerView = NSBundle.mainBundle().loadNibNamed("AddRecipientTableFooterView", owner: self, options: nil)[0] as! UIView
        footerView.frame = CGRectMake(0, 0, view.frame.width, 80.0)
        footerView.backgroundColor = UIColor.clearColor()
    
        var goToAddRecipientsTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "goToAddRecipients:")
        goToAddRecipientsTap.cancelsTouchesInView = false
        footerView.addGestureRecognizer(goToAddRecipientsTap)
        
        tableView.tableFooterView = footerView


    }
    
    @IBAction func goToAddRecipients(sender: AnyObject) {
        performSegueWithIdentifier("addRecipientsSegue", sender: self)
    }
}
