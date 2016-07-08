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
    
    func invoiceButtonInLetterController(letterViewController: POSLetterViewController) -> UIBarButtonItem {
        let invoiceButton =  UIButton(frame: CGRectMake(0, 0, 170, 44))
        invoiceButton.addTarget(letterViewController, action: #selector(letterViewController.didTapInvoice), forControlEvents: UIControlEvents.TouchUpInside)
        invoiceButton.setTitle(letterViewController.attachment.invoice.titleForInvoiceButtonLabel(letterViewController.sendingInvoice), forState: UIControlState.Normal)
        invoiceButton.setTitleColor(UIColor.digipostSpaceGrey(), forState: UIControlState.Normal)
        invoiceButton.titleLabel?.font = UIFont.systemFontOfSize(15)
        invoiceButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 3, right: 15)
        invoiceButton.accessibilityLabel = NSLocalizedString("actions toolbar invoice accessibility label", comment: "read when user taps invoice button on voice over")
        let invoiceBarButtonItem = UIBarButtonItem(customView: invoiceButton)
        return invoiceBarButtonItem
    }
    
    func infoBarButtonItemInLetterViewController(letterViewController: POSLetterViewController) -> UIBarButtonItem {
        let infoBarButtonItem = UIBarButtonItem(image: UIImage(named: "Info"), style: UIBarButtonItemStyle.Done, target: letterViewController, action: #selector(POSLetterViewController.didTapInformationBarButtonItem))
        infoBarButtonItem.accessibilityLabel = NSLocalizedString("actions toolbar info accessibility label", comment: "read when user taps the info button on voice over")
        return infoBarButtonItem
    }
    
    func moveDocumentBarButtonItemInLetterViewController(letterViewController: POSLetterViewController) -> UIBarButtonItem {
        let moveDocumentBarButtonItem = UIBarButtonItem(image: UIImage(named: "Move"), style: UIBarButtonItemStyle.Done, target: letterViewController, action: #selector(POSLetterViewController.didTapMoveDocumentBarButtonItem))
        
        moveDocumentBarButtonItem.accessibilityLabel = NSLocalizedString("actions toolbar move accessibility label", comment: "read when user taps move button on voice over")
        return moveDocumentBarButtonItem
    }
    
    func deleteDocumentBarButtonItemInLetterViewController(letterViewController: POSLetterViewController) -> UIBarButtonItem {
        let deleteDocumentBarButtonItem = UIBarButtonItem(image: UIImage(named: "Delete"), style: UIBarButtonItemStyle.Done, target: letterViewController, action: #selector(POSLetterViewController.didTapDeleteDocumentBarButtonItem))
        deleteDocumentBarButtonItem.accessibilityLabel = NSLocalizedString("actions toolbar delete accessibility label", comment: "read when user taps delete button on voice over")
        return deleteDocumentBarButtonItem
    }
    
    func renameDocumentBarButtonItemInLetterViewController(letterViewController: POSLetterViewController) -> UIBarButtonItem {
        let renameDocumentBarButtonItem = UIBarButtonItem(image: UIImage(named: "New name"), style: UIBarButtonItemStyle.Done, target: letterViewController, action: #selector(POSLetterViewController.didTapRenameDocumentBarButtonItem))
        
        renameDocumentBarButtonItem.accessibilityLabel = NSLocalizedString("actions toolbar rename accessibility label", comment: "read when user taps rename button on voice over")
        return renameDocumentBarButtonItem
    }
    
    func openDocumentBarButtonItemInLetterViewController(letterViewController: POSLetterViewController) -> UIBarButtonItem {
        let openDocumentBarButtonItem = UIBarButtonItem(image: UIImage(named: "Open_in"), style: UIBarButtonItemStyle.Done, target: letterViewController, action: #selector(POSLetterViewController.didTapOpenDocumentInExternalAppBarButtonItem))
        
        openDocumentBarButtonItem.accessibilityLabel = NSLocalizedString("actions toolbar openIn accessibility label", comment: "read when user taps openIn button on voice over")
        return openDocumentBarButtonItem
    }
    
    func setupIconsForLetterViewController(letterViewController: POSLetterViewController) -> NSArray{
        barTintColor = UIColor.whiteColor()
        
        let flexibleSpaceBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        let items = NSMutableArray()
        items.addObject(infoBarButtonItemInLetterViewController(letterViewController))
        items.addObject(flexibleSpaceBarButtonItem)
        
        if let attachment = letterViewController.attachment as POSAttachment? {
            if attachment.hasValidToPayInvoice() {
                if (attachment.mainDocument.boolValue){
                    items.addObjectsFromArray(itemsForValidInvoice(letterViewController) as [AnyObject])
                }else {
                    items.addObjectsFromArray(itemsForAttachmentThatIsInvoice(letterViewController) as [AnyObject])
                }
            } else {
                items.addObjectsFromArray(itemsForStandardLetter(letterViewController) as [AnyObject])
            }
        }else {
                items.addObjectsFromArray(itemsForReceipt(letterViewController) as [AnyObject])
        }
        
        self.tintColor = UIColor.digipostSpaceGrey()
        return items
    }
    
    private func itemsForValidInvoice (letterViewController: POSLetterViewController) -> NSArray {
        let items = NSMutableArray()
        let flexibleSpaceBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let moreOptionsBarButtonItem = UIBarButtonItem(image: UIImage(named: "More"), style: UIBarButtonItemStyle.Done, target: letterViewController, action: #selector(letterViewController.didTapMoreOptionsBarButtonItem))
        items.addObject(invoiceButtonInLetterController(letterViewController))
        items.addObject(flexibleSpaceBarButtonItem)
        items.addObject(moreOptionsBarButtonItem)
        return items
    }
    
    private func itemsForStandardLetter(letterViewController: POSLetterViewController) -> NSArray {
        let items = NSMutableArray()
        let flexibleSpaceBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        items.addObject(moveDocumentBarButtonItemInLetterViewController(letterViewController))
        items.addObject(flexibleSpaceBarButtonItem)
        items.addObject(deleteDocumentBarButtonItemInLetterViewController(letterViewController))
        items.addObject(flexibleSpaceBarButtonItem)
        items.addObject(renameDocumentBarButtonItemInLetterViewController(letterViewController))
        items.addObject(flexibleSpaceBarButtonItem)
        items.addObject(openDocumentBarButtonItemInLetterViewController(letterViewController))
        return items
    }
    
    private func itemsForReceipt(letterViewController: POSLetterViewController) -> NSArray {
        let items = NSMutableArray()
        let flexibleSpaceBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        items.addObject(deleteDocumentBarButtonItemInLetterViewController(letterViewController))
        items.addObject(flexibleSpaceBarButtonItem)
        items.addObject(openDocumentBarButtonItemInLetterViewController(letterViewController))
        return items
    }
    
    private func itemsForAttachmentThatIsInvoice(letterViewController: POSLetterViewController) -> NSArray {
        let items = NSMutableArray()
        let flexibleSpaceBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        items.addObject(invoiceButtonInLetterController(letterViewController))
        items.addObject(flexibleSpaceBarButtonItem)
        return items
    }
}
