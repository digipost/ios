//
//  Localization.swift
//  Digipost
//
//  Created by Håkon Bogen on 05/03/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import Foundation

/**
Version of NSLocalizedString that does not return key if does not find the localized string in table specified

:param: key       the key to look up
:param: tableName table to do look up in (filename for .strings file)
:param: comment   comment for the localization

:returns: a localized string if it finds it, else nil
*/
func LocalizedString(key: String, #tableName: String, #comment: String) -> String? {
    let string = NSLocalizedString(key, tableName: tableName, comment: comment)
    if (string == key) {
        return nil
    }
    return string
}