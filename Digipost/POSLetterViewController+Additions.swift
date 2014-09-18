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
        if (NSFileManager.defaultManager().fileExistsAtPath(decryptedFilePath)){
            fileURL = NSURL.fileURLWithPath(decryptedFilePath)
        } else if (NSFileManager.defaultManager().fileExistsAtPath(encryptedFilePath)){
            if (POSFileManager.sharedFileManager().decryptDataForBaseEncryptionModel(baseEncryptModel, error: &error)){
                fileURL = NSURL.fileURLWithPath(decryptedFilePath)
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
        }else {
            return false
        }
    }
}