//
//  ComposerModule.swift
//  Digipost
//
//  Created by Henrik Holmsen on 09.04.15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

extension UIImage{
    
    var base64Representation: String{
        get {
            let imageData:NSData = UIImagePNGRepresentation(self)
            return imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        }
    }
}

enum ComposerModuleType{
    case TextModule, ImageModule
}

class ComposerModule: NSObject {
    
    //MARK: - Properties
    
    // Common properties
    let type: ComposerModuleType
    var height:CGFloat?
    
    // TextModule properties
    let font: UIFont?
    var textAlignment: NSTextAlignment?
    let isEditing: Bool?
    var text: String?
    
    // ImageModule properties
    let image: UIImage?
    
    //MARK: - Class Initialisers
    
    init(textModuleWithFont font: UIFont){
        self.type = .TextModule
        self.font = font
        textAlignment = .Left
        self.height = 44
        super.init()
    }
    
    init(imageModuleWithImage image: UIImage){
        self.type = .ImageModule
        self.image = image
        self.height = image.size.height
        super.init()
    }
    
    //MARK: - Class Functions
    
    func htmlRepresentation(){
        //TODO: - Parse module to HTML
    }
    
    
}
