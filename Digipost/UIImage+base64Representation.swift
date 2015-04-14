//
//  UIImage+base64Representation.swift
//  Digipost
//
//  Created by Henrik Holmsen on 10.04.15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import Foundation

import UIKit

extension UIImage{
    
    var base64Representation: String{
        let imageData:NSData = UIImagePNGRepresentation(self)
        return imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
    }
}