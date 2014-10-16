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
        var error : NSError?
        if let decryptedFilePathNotNil = decryptedFilePath {
            if (NSFileManager.defaultManager().fileExistsAtPath(decryptedFilePathNotNil)){
                fileURL = NSURL.fileURLWithPath(decryptedFilePathNotNil)
            } else if (NSFileManager.defaultManager().fileExistsAtPath(encryptedFilePath)){
                if (POSFileManager.sharedFileManager().decryptDataForBaseEncryptionModel(baseEncryptModel, error: &error)){
                    fileURL = NSURL.fileURLWithPath(decryptedFilePathNotNil)
                }
            }
        }
        if let actualError = error {
            return false
        }
        if let updatedFileURL = fileURL? {
//            let interactionController = UIDocumentInteractionController(URL: updatedFileURL)
//            let canOpen = interactionController.presentOptionsMenuFromRect(CGRectZero, inView: UIView(frame: CGRectZero), animated: false)
//            interactionController.dismissMenuAnimated(false)
            return true
        } else {
            return false
        }
    }
    
    func showActionsActionSheet(view: UIView) {
//        UIActionSheet.showInView(self.view, withTitle: nslocalidstr, cancelButtonTitle: <#String!#>, destructiveButtonTitle: <#String!#>, otherButtonTitles: <#[AnyObject]!#>, tapBlock: <#UIActionSheetCompletionBlock!##(UIActionSheet!, Int) -> Void#>)
//        [UIActionSheet showInView:self.view withTitle:NSLocalizedString(@"upload action sheet title", @"") cancelButtonTitle:NSLocalizedString(@"upload action sheet cancel button", @"") destructiveButtonTitle:nil otherButtonTitles:@[NSLocalizedString(@"upload action sheet camera roll button", @"button that uploads from camera roll"),NSLocalizedString(@"upload action sheet camera", @"start camera")] tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
//            switch (buttonIndex) {
//            case 0:
//                break;
//            case 1:
//            default:
//                break;
//            }
//        }];
    }
}