//
//  UIAlertController+APIError.swift
//  Digipost
//
//  Created by Håkon Bogen on 04/02/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

extension UIAlertController {
    class func presentAlertControllerWithAPIError(apiError: APIError, presentingViewController: UIViewController) {
        presentAlertControllerWithAPIError(apiError, presentingViewController: presentingViewController, didTapOkClosure: nil)
    }
    
    class func presentAlertControllerWithAPIError(apiError: APIError, presentingViewController: UIViewController, didTapOkClosure: (() -> Void)? = nil) {
        if apiError.shouldBeShownToUser {
            let alertController = UIAlertController(title: apiError.alertTitle, message: apiError.altertMessage, preferredStyle: UIAlertControllerStyle.Alert)
            
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (alertAction) -> Void in
                didTapOkClosure?()
            })

            alertController.addAction(okAction)

            if presentingViewController.navigationController?.topViewController == presentingViewController && presentingViewController.presentedViewController == nil {
                presentingViewController.presentViewController(alertController, animated: true, completion:nil)
                Logger.dpostLogError("API error shown to user, code:\(apiError.code), digipostErrorcode: \(apiError.digipostErrorCode)")
            }
        }
    }
    
}
