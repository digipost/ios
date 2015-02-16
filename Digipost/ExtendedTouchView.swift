//
//  ExtendedTouchView.swift
//  Digipost
//
//  Created by Henrik Holmsen on 16.02.15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

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
