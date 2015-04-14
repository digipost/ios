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

    let type: ComposerModuleType
    
    init(type: ComposerModuleType){
        self.type = type
    }
    
    //MARK: - Class Functions
    
    func htmlRepresentation() -> String{
        //TODO: - Parse module to HTML
        return ""
    }
    
    
}
