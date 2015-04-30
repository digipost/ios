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
        if apiError.shouldBeShownToUser {
            let alertController = UIAlertController(title: apiError.alertTitle, message: apiError.altertMessage, preferredStyle: UIAlertControllerStyle.Alert)
            
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (alertAction) -> Void in
                
            })
            
            alertController.addAction(okAction)
            presentingViewController.presentViewController(alertController, animated: true, completion: { () -> Void in
                
            })
        }
    }
    
    class func presentAlertControllerWithAPIError(apiError: APIError, presentingViewController: UIViewController, didTapOkClosure: () -> Void ) {
        if apiError.shouldBeShownToUser {
            let alertController = UIAlertController(title: apiError.alertTitle, message: apiError.altertMessage, preferredStyle: UIAlertControllerStyle.Alert)
            
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (alertAction) -> Void in
                didTapOkClosure()
            })
            
            alertController.addAction(okAction)
            presentingViewController.presentViewController(alertController, animated: true, completion: { () -> Void in
                
            })
            
        }
    }
    
}
