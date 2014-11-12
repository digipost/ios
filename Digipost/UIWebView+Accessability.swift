//
//  UIWebView+Accessability.swift
//  Digipost
//
//  Created by Håkon Bogen on 30/10/14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

import UIKit

extension UIWebView {
    
    func setAccessabilityLabelForFileType(filetype: String?){
        if let actualFileType = filetype as String? {
            
            if filetype == "jpg" || filetype == "png" {
                accessibilityLabel = NSLocalizedString("accessability label webview is image", comment: "when webview is image read this text")
                accessibilityHint = NSLocalizedString("accessability label webview is image", comment: "when webview is image read this text")
                accessibilityFrame = CGRectMake(0, 0, 100, 100);
            }
        }
    }
    
}
