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

import Foundation
import UIKit



extension POSLetterViewController {
    
    func interactionControllerCanShareContent(_ baseEncryptModel: POSBaseEncryptedModel) -> Bool{
        
        let encryptedFilePath = baseEncryptModel.encryptedFilePath()
        let decryptedFilePath = baseEncryptModel.decryptedFilePath()
        var fileURL : URL?
        
        if let decryptedFilePathNotNil = decryptedFilePath {
            if (FileManager.default.fileExists(atPath: decryptedFilePathNotNil)){
                fileURL = URL(fileURLWithPath: decryptedFilePathNotNil)
            } else if (FileManager.default.fileExists(atPath: encryptedFilePath!)){
                do {
                    try POSFileManager.shared().decryptData(forBaseEncryptionModel: baseEncryptModel)
                    fileURL = URL(fileURLWithPath: decryptedFilePathNotNil)
                } catch {
                    return false
                }
            }
        }
        
        if let _ = fileURL {
            return true
        } else {
            return false
        }
    }
    
    @objc func addTapGestureRecognizersToWebView(_ webView: UIWebView) {
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(POSLetterViewController.didSingleTapWebView))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.numberOfTouchesRequired = 1
        singleTapGestureRecognizer.delegate = self
        webView.addGestureRecognizer(singleTapGestureRecognizer)
        
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(POSLetterViewController.didDoubleTapWebView))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        doubleTapGestureRecognizer.numberOfTouchesRequired = 1
        doubleTapGestureRecognizer.delegate = self
        webView.addGestureRecognizer(doubleTapGestureRecognizer)
        
        singleTapGestureRecognizer.require(toFail: doubleTapGestureRecognizer)
    }
    
    @objc func shouldHideToolBar(_ attachment: POSAttachment?) -> Bool {
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
    }
}
