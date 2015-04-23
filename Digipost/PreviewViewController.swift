//
//  PreviewViewController.swift
//  Digipost
//
//  Created by Henrik Holmsen on 08.04.15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController, RecipientsViewControllerDelegate, UIWebViewDelegate {
    
    var recipients = [Recipient]()
    var modules = [ComposerModule]()

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var addRecipientsButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var webViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var recipientsHeaderLabel: UILabel!
    @IBOutlet weak var previewHeaderLabel: UILabel!
    @IBOutlet weak var sendButton: UIBarButtonItem!

    // the selected digipost address for the mailbox that should show as sender when sending current compsing letter
    var mailboxDigipostAddress : String?

    var currentShowingHTMLContent : String?


    override func viewDidLoad() {
        super.viewDidLoad()
        webView.delegate = self
        webView.scrollView.scrollEnabled = false
        
        ComposerModuleParser.parseComposerModuleContentToHTML(modules, response: { [unowned self] (htmlString) -> ()  in
            self.webView.loadHTMLString(htmlString, baseURL: nil)
            self.currentShowingHTMLContent = htmlString!
            
            })
        
        title = NSLocalizedString("preview view navigation bar title", comment: "Navigation bar title in preview view")
        addRecipientsButton.setTitle(NSLocalizedString("preview view recipients add recipients button title", comment: "Add reciepients button"), forState: .Normal)
        sendButton.title = NSLocalizedString("preview view recipients send button title", comment: "Send button")
        
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: self.webView.scrollView.contentSize.height + 300)
        webViewHeightConstraint.constant = self.webView.scrollView.contentSize.height
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
                
        if recipients.count == 0 {
            recipientsHeaderLabel.text = NSLocalizedString("preview view recipients header title no recipients", comment: "Recipients view header no recipients")
        } else if recipients.count == 1 {
            recipientsHeaderLabel.text = NSLocalizedString("preview view recipients header title one recipient", comment: "Recipients view header one recipient")
        } else {
            let localizedString = NSLocalizedString("preview view recipients header title recipients", comment: "Recipients view header many recipients")
            recipientsHeaderLabel.text = "\(recipients.count) \(localizedString)"
        }
        
        previewHeaderLabel.text = NSLocalizedString("preview view header title", comment: "Preview view header")
    
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
