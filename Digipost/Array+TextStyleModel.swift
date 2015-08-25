//
//  Array+TextStyleModel.swift
//  Digipost
//
//  Created by Håkon Bogen on 25/08/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

extension Array {

    func selectedTextStyleModel() -> TextStyleModel? {
        for object in self {
            if let textStyleModel = object as? TextStyleModel {
                if textStyleModel.enabled == true {
                    return textStyleModel
                }
            }
        }
        return nil
    }

    func setTextStyleModelEnabledAndAllOthersDisabled(textstyleModel : TextStyleModel) {
        for object in self {
            if let aTextStyleModel = object as? TextStyleModel {
                if aTextStyleModel.keyword == textstyleModel.keyword {
                    aTextStyleModel.enabled = true
                } else {
                    aTextStyleModel.enabled = false
                }
            }
        }
    }
}
