//
//  ComposerTextModule.swift
//  Digipost
//
//  Created by Henrik Holmsen on 14.04.15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import Foundation

class TextComposerModule: ComposerModule {
    
    var height:CGFloat
    let font: UIFont?
    var textAlignment: NSTextAlignment?
    let isEditing: Bool?
    var text: String?

    init(moduleWithFont font: UIFont) {
        self.font = font
        textAlignment = .Left
        self.height = 44
        self.isEditing = false
        super.init()
    }
}