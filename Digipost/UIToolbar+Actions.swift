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

extension UIToolbar {
    
    func invoiceButtonInLetterController(_ letterViewController: POSLetterViewController) -> UIBarButtonItem {
        let invoiceButton =  UIButton(frame: CGRect(x: 0, y: 0, width: 170, height: 44))
        invoiceButton.addTarget(letterViewController, action: #selector(letterViewController.didTapInvoice), for: UIControlEvents.touchUpInside)
        invoiceButton.setTitle(letterViewController.attachment.invoice.titleForInvoiceButtonLabel(letterViewController.isSendingInvoice), for: UIControlState())
        invoiceButton.setTitleColor(UIColor.digipostSpaceGrey(), for: UIControlState())
        invoiceButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        invoiceButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 3, right: 15)
        invoiceButton.accessibilityLabel = NSLocalizedString("actions toolbar invoice accessibility label", comment: "read when user taps invoice button on voice over")
        let invoiceBarButtonItem = UIBarButtonItem(customView: invoiceButton)
        return invoiceBarButtonItem
    }
    
    func infoBarButtonItemInLetterViewController(_ letterViewController: POSLetterViewController) -> UIBarButtonItem {
        let infoBarButtonItem = UIBarButtonItem(image: UIImage(named: "Info"), style: UIBarButtonItemStyle.done, target: letterViewController, action: #selector(POSLetterViewController.didTapInformationBarButtonItem))
        infoBarButtonItem.accessibilityLabel = NSLocalizedString("actions toolbar info accessibility label", comment: "read when user taps the info button on voice over")
        return infoBarButtonItem
    }
    
    func moveDocumentBarButtonItemInLetterViewController(_ letterViewController: POSLetterViewController) -> UIBarButtonItem {
        let moveDocumentBarButtonItem = UIBarButtonItem(image: UIImage(named: "Move"), style: UIBarButtonItemStyle.done, target: letterViewController, action: #selector(POSLetterViewController.didTapMoveDocumentBarButtonItem))
        
        moveDocumentBarButtonItem.accessibilityLabel = NSLocalizedString("actions toolbar move accessibility label", comment: "read when user taps move button on voice over")
        return moveDocumentBarButtonItem
    }
    
    func deleteDocumentBarButtonItemInLetterViewController(_ letterViewController: POSLetterViewController) -> UIBarButtonItem {
        let deleteDocumentBarButtonItem = UIBarButtonItem(image: UIImage(named: "Delete"), style: UIBarButtonItemStyle.done, target: letterViewController, action: #selector(POSLetterViewController.didTapDeleteDocumentBarButtonItem))
        deleteDocumentBarButtonItem.accessibilityLabel = NSLocalizedString("actions toolbar delete accessibility label", comment: "read when user taps delete button on voice over")
        return deleteDocumentBarButtonItem
    }
    
    func renameDocumentBarButtonItemInLetterViewController(_ letterViewController: POSLetterViewController) -> UIBarButtonItem {
        let renameDocumentBarButtonItem = UIBarButtonItem(image: UIImage(named: "New name"), style: UIBarButtonItemStyle.done, target: letterViewController, action: #selector(POSLetterViewController.didTapRenameDocumentBarButtonItem))
        
        renameDocumentBarButtonItem.accessibilityLabel = NSLocalizedString("actions toolbar rename accessibility label", comment: "read when user taps rename button on voice over")
        return renameDocumentBarButtonItem
    }
    
    func openDocumentBarButtonItemInLetterViewController(_ letterViewController: POSLetterViewController) -> UIBarButtonItem {
        let openDocumentBarButtonItem = UIBarButtonItem(image: UIImage(named: "Open_in"), style: UIBarButtonItemStyle.done, target: letterViewController, action: #selector(POSLetterViewController.didTapOpenDocumentInExternalAppBarButtonItem))
        
        openDocumentBarButtonItem.accessibilityLabel = NSLocalizedString("actions toolbar openIn accessibility label", comment: "read when user taps openIn button on voice over")
        return openDocumentBarButtonItem
    }
    
    func setupIconsForLetterViewController(_ letterViewController: POSLetterViewController) -> NSArray{
        barTintColor = UIColor.white
        
        let flexibleSpaceBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        let items = NSMutableArray()
        items.add(infoBarButtonItemInLetterViewController(letterViewController))
        items.add(flexibleSpaceBarButtonItem)
        
        if let attachment = letterViewController.attachment as POSAttachment? {
            if attachment.hasValidToPayInvoice() {
                if (attachment.mainDocument.boolValue){
                    items.addObjects(from: itemsForValidInvoice(letterViewController) as [AnyObject])
                }else {
                    items.addObjects(from: itemsForAttachmentThatIsInvoice(letterViewController) as [AnyObject])
                }
            } else {
                items.addObjects(from: itemsForStandardLetter(letterViewController) as [AnyObject])
            }
        }else {
                items.addObjects(from: itemsForReceipt(letterViewController) as [AnyObject])
        }
        
        self.tintColor = UIColor.digipostSpaceGrey()
        return items
    }
    
    fileprivate func itemsForValidInvoice (_ letterViewController: POSLetterViewController) -> NSArray {
        let items = NSMutableArray()
        let flexibleSpaceBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let moreOptionsBarButtonItem = UIBarButtonItem(image: UIImage(named: "More"), style: UIBarButtonItemStyle.done, target: letterViewController, action: #selector(letterViewController.didTapMoreOptionsBarButtonItem))
        
        let invoiceIsSentToBank = letterViewController.attachment.invoice.timePaid != nil
        if(!InvoiceBankAgreement.hasActiveAgreementType2() || invoiceIsSentToBank){
            items.add(invoiceButtonInLetterController(letterViewController))
        }
        
        items.add(flexibleSpaceBarButtonItem)
        items.add(moreOptionsBarButtonItem)
        return items
    }
    
    fileprivate func itemsForStandardLetter(_ letterViewController: POSLetterViewController) -> NSArray {
        let items = NSMutableArray()
        let flexibleSpaceBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        items.add(moveDocumentBarButtonItemInLetterViewController(letterViewController))
        items.add(flexibleSpaceBarButtonItem)
        items.add(deleteDocumentBarButtonItemInLetterViewController(letterViewController))
        items.add(flexibleSpaceBarButtonItem)
        items.add(renameDocumentBarButtonItemInLetterViewController(letterViewController))
        items.add(flexibleSpaceBarButtonItem)
        items.add(openDocumentBarButtonItemInLetterViewController(letterViewController))
        return items
    }
    
    fileprivate func itemsForReceipt(_ letterViewController: POSLetterViewController) -> NSArray {
        let items = NSMutableArray()
        let flexibleSpaceBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        items.add(deleteDocumentBarButtonItemInLetterViewController(letterViewController))
        items.add(flexibleSpaceBarButtonItem)
        items.add(openDocumentBarButtonItemInLetterViewController(letterViewController))
        return items
    }
    
    fileprivate func itemsForAttachmentThatIsInvoice(_ letterViewController: POSLetterViewController) -> NSArray {
        let items = NSMutableArray()
        let flexibleSpaceBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        items.add(invoiceButtonInLetterController(letterViewController))
        items.add(flexibleSpaceBarButtonItem)
        return items
    }
}
