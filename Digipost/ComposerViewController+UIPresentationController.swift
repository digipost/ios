//
//  ComposerViewController+UIPresentationController.swift
//  Digipost
//
//  Created by Håkon Bogen on 07/05/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

extension ComposerViewController : UIViewControllerTransitioningDelegate {
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController!, sourceViewController source: UIViewController) -> UIPresentationController? {
        return ComposerPresentationController(presentedViewController: presented, presentingViewController: presenting)
    }
 
}

