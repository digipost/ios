//
//  UIToolbar+Actions.swift
//  Digipost
//
//  Created by Håkon Bogen on 23/10/14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

import UIKit

extension UIToolbar {
    
    
    func setupIconsForLetterViewController(letterViewController: POSLetterViewController){
        barTintColor = UIColor.whiteColor()
        
        let image = UIImage(named: "Info.pdf")
        
        let infoBarButtonItem = UIBarButtonItem(image: UIImage(named: "Info"), style: UIBarButtonItemStyle.Done, target: letterViewController, action: Selector("didTapInformationBarButtonItem:"))
        let flexibleSpaceBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        let invoiceButton =  UIButton(frame: CGRectMake(0, 0, 170, 44))
        invoiceButton.setImage(UIImage(named: "Pay_Bill"), forState: UIControlState.Normal)
        invoiceButton.addTarget(letterViewController, action: Selector("didTapInvoice:"), forControlEvents: UIControlEvents.TouchUpInside)
        invoiceButton.setTitle("Send til nettbank", forState: UIControlState.Normal)
        invoiceButton.setTitleColor(UIColor.digipostSpaceGrey(), forState: UIControlState.Normal)
        invoiceButton.titleLabel?.font = UIFont.systemFontOfSize(15)
        invoiceButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 3, right: 15)
        let invoiceBarButtonItem = UIBarButtonItem(customView: invoiceButton)
        
        let moreOptionsBarButtonItem = UIBarButtonItem(image: UIImage(named: "More"), style: UIBarButtonItemStyle.Done, target: letterViewController, action: Selector("didTapMoreOptionsBarBarButtonItem"))
        
        
        let items = NSMutableArray()
        items.addObject(infoBarButtonItem)
        items.addObject(flexibleSpaceBarButtonItem)
        items.addObject(invoiceBarButtonItem)
        items.addObject(flexibleSpaceBarButtonItem)
        items.addObject(moreOptionsBarButtonItem)
        setItems(items, animated: true)
        self.tintColor = UIColor.digipostSpaceGrey()
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