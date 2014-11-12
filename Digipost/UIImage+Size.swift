//
//  UIImage+Size.swift
//  Digipost
//
//  Created by Håkon Bogen on 03.10.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

import Foundation

extension UIImage {
    func scaleToSize(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0);
        self.drawInRect(CGRectMake(0, 0, size.width, size.height))
        var newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}