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

extension UIWindow {
    func topMasterViewController() -> UIViewController {
        if let navController = rootViewController as? UINavigationController  {
            return navController.topViewController!
        }
        if let splitViewController = rootViewController as? UISplitViewController {
            if let navController = splitViewController.viewControllers[0] as? UINavigationController{
                return navController.topViewController!
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
        let returnValue = false
        if (UIDevice.current.userInterfaceIdiom == .pad ){
            let navigationController = topMasterNavigationController()
            if let viewControllers = navigationController?.viewControllers as NSArray? {
                if (viewControllers.count == 3){
                    if let _ = viewControllers[0] as? AccountViewController {
                        if let _ = viewControllers[1] as? POSFoldersViewController {
                            if let _ = viewControllers[2] as? POSDocumentsViewController {
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
