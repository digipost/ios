//
//  ExtendedTouchView.swift
//  Digipost
//
//  Created by Henrik Holmsen on 16.02.15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

// This class is set as the custom view for the view in the new features viewcontroller.
// Its function is to redirect all touch events to the scrollview in viewcontroller.

class ExtendedTouchView: UIView {

    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        
        if pointInside(point, withEvent: event) {
            for subview in subviews as [UIView] {
                if subview .isKindOfClass(UIScrollView) {
                    return subview
                }
            }
        }
        
        return nil
    }
}
