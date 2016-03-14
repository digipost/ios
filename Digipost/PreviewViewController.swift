//
// Copyright (C) Posten Norge AS
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//         http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import UIKit
import SingleLineShakeAnimation

class PreviewViewController: UIViewController, UIWebViewDelegate, UINavigationControllerDelegate {
    
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
        
        if let actualCurrentShowingHTMLContent = currentShowingHTMLContent{
            self.webView.loadHTMLString(actualCurrentShowingHTMLContent, baseURL: nil)
        }
        title = NSLocalizedString("preview view navigation bar title", comment: "Navigation bar title in preview view")
        sendButton.title = NSLocalizedString("preview view recipients send button title", comment: "Send button")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "recipientReceivedFromRecipientViewController:", name: "addRecipientNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "recipientDeletedFromRecipientViewController:", name: "deleteRecipientNotification", object: nil)
        navigationController?.delegate = self
    }
    
    func recipientReceivedFromRecipientViewController(notification: NSNotification) {
        recipients.append(notification.object as! Recipient)
    }
    
    func recipientDeletedFromRecipientViewController(notification: NSNotification) {
        let receivedRecipient = notification.object as! Recipient
        
        if recipients.count > 0 {
            for (index, recipient) in recipients.enumerate() {
                if recipient.digipostAddress == receivedRecipient.digipostAddress {
                    recipients.removeAtIndex(index)
                    break
                }
            }
        }
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: self.webView.scrollView.contentSize.height)
        webViewHeightConstraint.constant = self.webView.scrollView.contentSize.height
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        previewHeaderLabel.text = NSLocalizedString("preview view header title", comment: "Preview view header")
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addRecipientsButton.setTitle(NSLocalizedString("preview view recipients add recipients button title", comment: "Add reciepients button"), forState: .Normal)
        let recipientNames = self.recipients.map { (recipient) -> String in
            return recipient.firstName()
        }
        addRecipientsButton.fitAsManyStringsAsPossible(recipientNames)
        
        if recipients.count == 0 {
            recipientsHeaderLabel.text = NSLocalizedString("preview view recipients header title no recipients", comment: "Recipients view header no recipients")
        } else if recipients.count == 1 {
            recipientsHeaderLabel.text = NSLocalizedString("preview view recipients header title one recipient", comment: "Recipients view header one recipient")
        } else {
            let localizedString = NSLocalizedString("preview view recipients header title recipients", comment: "Recipients view header many recipients")
            recipientsHeaderLabel.text = "\(recipients.count) \(localizedString)"
        }
        
    }
    
    @IBAction func didTapFooterView(sender: AnyObject) {
        performSegueWithIdentifier("addRecipientsSegue", sender: self)
    }
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {        
        if let composerViewController = viewController as? ComposerViewController {
            composerViewController.recipients = recipients
            NSNotificationCenter.defaultCenter().removeObserver(self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let recipientsViewController = segue.destinationViewController as? RecipientViewController {
            if recipients.count > 0 {
                recipientsViewController.addedRecipients = recipients
            }
        }
        
        if let composerViewController = segue.destinationViewController as? ComposerViewController {
            composerViewController.recipients = recipients
        }
    }
    
    func animateShowingUserHasToAddRecipientsBeforeSending() {
        addRecipientsButton.shake(.Horizontal, numberOfTimes: 9, totalDuration: 0.6) {
            
        }
    }
    
    @IBAction func didTapSendButton(sender: AnyObject) {
        if recipients.count == 0 {
            animateShowingUserHasToAddRecipientsBeforeSending()
            return
        }
        
        let mailbox = POSMailbox.existingMailboxWithDigipostAddress(mailboxDigipostAddress, inManagedObjectContext: POSModelManager.sharedManager().managedObjectContext)
        APIClient.sharedClient.send(currentShowingHTMLContent!, recipients: recipients, uri: mailbox.sendUri, success: { () -> Void in
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                
            })
            
            }) { (error) -> () in
                print(error)
        }
    }
    
}
