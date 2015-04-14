//
//  ComposerModule.swift
//  Digipost
//
//  Created by Henrik Holmsen on 09.04.15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

enum ComposerModuleType{
    case TextModule, ImageModule
}

class ComposerModule: NSObject {
    
    //MARK: - Properties
    
    // Common properties
    let type: ComposerModuleType
    var height:CGFloat
    
    // TextModule properties
    let font: UIFont?
    var textAlignment: NSTextAlignment?
    let isEditing: Bool?
    var text: String?
    
    // ImageModule properties
    var image: UIImage?
    
    //MARK: - Class Initialisers
    
    init(moduleWithFont font: UIFont){
        self.type = .TextModule
        self.font = font
        textAlignment = .Left
        self.height = 44
        self.isEditing = false
        super.init()
    }
    
    init(moduleWithImage image: UIImage){
        self.type = .ImageModule
        self.image = image
        self.height = image.size.height
        self.isEditing = false
        self.font = UIFont()
        super.init()
    }
    
    //MARK: - Class Functions
    
    func htmlRepresentation() -> String{
        //TODO: - Parse module to HTML
        return ""
    }
    
    
}
