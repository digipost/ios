//
//  ComposerPresentationController.swift
//  Digipost
//
//  Created by Håkon Bogen on 07/05/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

class ComposerPresentationController: UIPresentationController {

    var preferredHeight : CGFloat
    var preferredYOrigin : CGFloat

    override func shouldPresentInFullscreen() -> Bool {
        return false
    }

    override func frameOfPresentedViewInContainerView() -> CGRect {
        let bounds = UIScreen.mainScreen().bounds
        println(bounds)
        return CGRectMake(0, 400, bounds.size.width, 300)
    }

    override func presentationTransitionWillBegin() {

    }

}
