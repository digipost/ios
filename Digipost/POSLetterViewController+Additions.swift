//
//  POSLetterViewController+Additions.swift
//  Digipost
//
//  Created by Håkon Bogen on 17.09.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

import Foundation
import UIKit



extension POSLetterViewController {
    
    func interactionControllerCanShareContent(baseEncryptModel: POSBaseEncryptedModel) -> Bool{
        
        let encryptedFilePath = baseEncryptModel.encryptedFilePath()
        let decryptedFilePath = baseEncryptModel.decryptedFilePath()
        var fileURL : NSURL?
        
        if let decryptedFilePathNotNil = decryptedFilePath {
            if (NSFileManager.defaultManager().fileExistsAtPath(decryptedFilePathNotNil)){
                fileURL = NSURL.fileURLWithPath(decryptedFilePathNotNil)
            } else if (NSFileManager.defaultManager().fileExistsAtPath(encryptedFilePath)){
                do {
                    try POSFileManager.sharedFileManager().decryptDataForBaseEncryptionModel(baseEncryptModel)
                    fileURL = NSURL.fileURLWithPath(decryptedFilePathNotNil)
                } catch {
                    return false
                }
            }
        }
        
        if let updatedFileURL = fileURL {
            //            let interactionController = UIDocumentInteractionController(URL: updatedFileURL)
            //            let canOpen = interactionController.presentOptionsMenuFromRect(CGRectZero, inView: UIView(frame: CGRectZero), animated: false)
            //            interactionController.dismissMenuAnimated(false)
            return true
        } else {
            return false
        }
    }
    func addTapGestureRecognizersToWebView(webView: UIWebView) {
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("didSingleTapWebView:"))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.numberOfTouchesRequired = 1
        singleTapGestureRecognizer.delegate = self
        webView.addGestureRecognizer(singleTapGestureRecognizer)
        
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("didDoubleTapWebView:"))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        doubleTapGestureRecognizer.numberOfTouchesRequired = 1
        doubleTapGestureRecognizer.delegate = self
        webView.addGestureRecognizer(doubleTapGestureRecognizer)
        
        singleTapGestureRecognizer.requireGestureRecognizerToFail(doubleTapGestureRecognizer)
    }
    
    func shouldHideToolBar(attachment: POSAttachment?) -> Bool {
        if let actualAttachment = attachment as POSAttachment! {
            if actualAttachment.invoice != nil{
                return false
            }
            if let mainDocumentNumber = actualAttachment.mainDocument as NSNumber? {
                if mainDocumentNumber.boolValue == false {
                    return true
                }
                
            }
        }
        return false
        //        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        //            if (!self.attachment && !self.receipt) {
        //                [self showEmptyView:YES];
        //                [self.navigationController setToolbarHidden:YES animated:YES];
        //                return;
        //            } else {
        //                
        //                [self showEmptyView:NO];
        //            }
        //        }
        //        if (self.receipt || self.attachment.mainDocument.boolValue == NO) {
        //            [self.navigationController setToolbarHidden:YES animated:YES];
        //        } else {
        //            [self.navigationController setToolbarHidden:NO animated:YES];
        //        }
        //        if ([self attachmentHasValidFileType] == NO) {
        //            [self showInvalidFileTypeView];
        //        }
    }
}