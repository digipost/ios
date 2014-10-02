//
//  UINavigationController+Extensions.swift
//  Digipost
//
//  Created by Håkon Bogen on 02.10.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

import Foundation

extension UINavigationController {
    func documentsViewControllerInHierarchy() -> POSDocumentsViewController? {
        for (index, obj : AnyObject) in enumerate(viewControllers) {
            if let documentsViewController = obj as? POSDocumentsViewController {
                return documentsViewController
            }
        }
        return nil
    }
    func foldersViewControllerInHierarchy() -> POSFoldersViewController? {
        for (index, obj : AnyObject) in enumerate(viewControllers) {
            if let foldersViewController = obj as? POSFoldersViewController {
                return foldersViewController
            }
        }
        return nil
    }
}