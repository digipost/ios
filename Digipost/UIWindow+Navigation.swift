//
//  UIWindowExtension.swift
//  Digipost
//
//  Created by Håkon Bogen on 16.09.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

import Foundation
import UIKit

extension UIWindow {
    func topMasterViewController() -> UIViewController {
        if let navController = rootViewController as? UINavigationController  {
            return navController.topViewController
        }
        if let splitViewController = rootViewController as? UISplitViewController {
            if let navController = splitViewController.viewControllers[0] as? UINavigationController{
                return navController.topViewController
            }
        }
        return rootViewController!
    }
    
    func topMasterNavigationController() -> UINavigationController? {
        if let navController = rootViewController as? UINavigationController  {
            return navController
        }
        if let splitViewController = rootViewController as? UISplitViewController {
            if let navController = splitViewController.viewControllers[0] as? UINavigationController{
                return navController
            }
        }
        return nil
    }
    
    func hasCorrectNavigationHierarchyForShowingDocuments() -> Bool {
        var returnValue = false
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad ){
            let navigationController = topMasterNavigationController()
            if let viewControllers = navigationController?.viewControllers as NSArray? {
                if (viewControllers.count == 3){
                    if let rootcontroller = viewControllers[0] as? POSAccountViewController {
                        if let secondController = viewControllers[1] as? POSFoldersViewController {
                            if let thirdController = viewControllers[2] as? POSDocumentsViewController {
                                return true
                            }
                        }
                        
                    }
                }
            }
            
        }
        return returnValue
    }
}