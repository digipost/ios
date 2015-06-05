//
//  UIImageView+Color.swift
//  Digipost
//
//  Created by Håkon Bogen on 06/11/14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func imageViewWithTintColor(imageNamed: String, color: UIColor) -> UIImageView {
        let image = UIImage(named: imageNamed)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.tintColor = color
        return imageView
    }
    
}
