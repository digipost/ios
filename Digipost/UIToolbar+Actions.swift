//
//  UIToolbar+Actions.swift
//  Digipost
//
//  Created by Håkon Bogen on 23/10/14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

import UIKit

extension UIToolbar {
    
    
    func setupIconsForLetterViewController(letterViewController: POSLetterViewController) -> NSArray{
        
        barTintColor = UIColor.whiteColor()
        let image = UIImage(named: "Info.pdf")
        
        let infoBarButtonItem = UIBarButtonItem(image: UIImage(named: "Info"), style: UIBarButtonItemStyle.Done, target: letterViewController, action: Selector("didTapInformationBarButtonItem:"))
        let flexibleSpaceBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        let items = NSMutableArray()
        items.addObject(infoBarButtonItem)
        items.addObject(flexibleSpaceBarButtonItem)
        
        if let attachment = letterViewController.attachment as POSAttachment? {
            if attachment.hasValidToPayInvoice() {
                items.addObjectsFromArray(itemsForValidInvoice(letterViewController))
            } else {
                items.addObjectsFromArray(itemsForStandardLetter(letterViewController))
            }
        }else {
                items.addObjectsFromArray(itemsForStandardLetter(letterViewController))
        }
        
        self.tintColor = UIColor.digipostSpaceGrey()
        return items
    }
    
    private func itemsForValidInvoice (letterViewController: POSLetterViewController) -> NSArray {
        let items = NSMutableArray()
        let flexibleSpaceBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        let invoiceButton =  UIButton(frame: CGRectMake(0, 0, 170, 44))
        invoiceButton.addTarget(letterViewController, action: Selector("didTapInvoice:"), forControlEvents: UIControlEvents.TouchUpInside)
        invoiceButton.setTitle(letterViewController.attachment.invoice.titleForInvoiceButtonLabel(letterViewController.sendingInvoice), forState: UIControlState.Normal)
        invoiceButton.setTitleColor(UIColor.digipostSpaceGrey(), forState: UIControlState.Normal)
        invoiceButton.titleLabel?.font = UIFont.systemFontOfSize(15)
        invoiceButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 3, right: 15)
        let invoiceBarButtonItem = UIBarButtonItem(customView: invoiceButton)
        
        let moreOptionsBarButtonItem = UIBarButtonItem(image: UIImage(named: "More"), style: UIBarButtonItemStyle.Done, target: letterViewController, action: Selector("didTapMoreOptionsBarButtonItem:"))
        
        items.addObject(invoiceBarButtonItem)
        items.addObject(flexibleSpaceBarButtonItem)
        items.addObject(moreOptionsBarButtonItem)
        
        return items
    }
    
    private func itemsForStandardLetter(letterViewController: POSLetterViewController) -> NSArray {
        let items = NSMutableArray()
        let flexibleSpaceBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        let moveDocumentBarButtonItem = UIBarButtonItem(image: UIImage(named: "Move"), style: UIBarButtonItemStyle.Done, target: letterViewController, action: Selector("didTapMoveDocumentBarButtonItem:"))
        
        let deleteDocumentBarButtonItem = UIBarButtonItem(image: UIImage(named: "Delete"), style: UIBarButtonItemStyle.Done, target: letterViewController, action: Selector("didTapDeleteDocumentBarButtonItem:"))
        
        let renameDocumentBarButtonItem = UIBarButtonItem(image: UIImage(named: "New name"), style: UIBarButtonItemStyle.Done, target: letterViewController, action: Selector("didTapRenameDocumentBarButtonItem:"))
        
        let openDocumentBarButtonItem = UIBarButtonItem(image: UIImage(named: "Open_in"), style: UIBarButtonItemStyle.Done, target: letterViewController, action: Selector("didTapOpenDocumentInExternalAppBarButtonItem:"))
        
        items.addObject(moveDocumentBarButtonItem)
        items.addObject(flexibleSpaceBarButtonItem)
        items.addObject(deleteDocumentBarButtonItem)
        items.addObject(flexibleSpaceBarButtonItem)
        items.addObject(renameDocumentBarButtonItem)
        items.addObject(flexibleSpaceBarButtonItem)
        items.addObject(openDocumentBarButtonItem)
        return items
        
    }
}


//- (void)didTapInformationBarButtonItem:(id)sender
//{
//    [self setInfoViewVisible:YES];
//}
//
//- (void)didTapMoveDocumentBarButtonItem:(id)sender
//{
//    
//}
//
//- (void)didTapDeleteDocumentBarButtonItem:(id)sender
//{
//    
//}
//- (void)didTapRenameDocumentBarButtonItem:(id)sender
//{
//    
//}
//
//- (void)didTapOpenDocumentInExternalAppBarButtonItem:(id)sender
//{
//    
//}