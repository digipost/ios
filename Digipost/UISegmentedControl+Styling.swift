//
//  UISegmentedControl+Styling.swift
//  Digipost
//
//  Created by Håkon Bogen on 15/07/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

extension UISegmentedControl {

    func removeBorders() {
        setBackgroundImage(imageWithColor(UIColor.whiteColor()), forState: .Normal, barMetrics: .Default)
        setBackgroundImage(imageWithColor(tintColor!), forState: .Selected, barMetrics: .Default)
        setDividerImage(imageWithColor(UIColor.clearColor()), forLeftSegmentState: .Normal, rightSegmentState: .Normal, barMetrics: .Default)
    }

    func setupWithDigipostFont() {
        let font = UIFont.boldSystemFontOfSize(19)
        let attributes = [NSFontAttributeName : font]
        self.setTitleTextAttributes(attributes, forState: .Normal)
    }

    // create a 1x1 image with this color
    private func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRectMake(0.0, 0.0, 1.0, 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextFillRect(context, rect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image
    }
}
