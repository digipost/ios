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
                Logger.dpostLogWarning("A web request failed and returned a an API error with code: \(apiError.code) , internal Digipost error-code: \(apiError.digipostErrorCode)", location: "Unknown", UI: "User got an error popup with title \(apiError.alertTitle)", cause: "Cause can be translated from the error code")
            }
        }
    }

    class func forcedLogoutAlertController() -> UIAlertController {
        let alertController = UIAlertController(title:NSLocalizedString("Oauth login error title", comment:""), message: NSLocalizedString("Oauth login error message", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(alertAction)
        return alertController
    }
}
