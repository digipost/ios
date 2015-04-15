//
//  ComposerImageModule.swift
//  Digipost
//
//  Created by Henrik Holmsen on 14.04.15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import Foundation

class ImageComposerModule: ComposerModule {
    
    var height:CGFloat
    var image: UIImage?

    init(image: UIImage) {
        self.image = image
        self.height = 44
        super.init()
    }
    
}