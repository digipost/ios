//
//  String+Composer.swift
//  Digipost
//
//  Created by Håkon Bogen on 06/07/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

extension String {
    
    /**
    Inserts a substring at the given index in self.
    :param: index Where the new string is inserted
    :param: string String to insert
    :returns: String formed from self inserting string at index
    */
    func insert (var index: Int, _ string: String) -> String {
        //  Edge cases, prepend and append
        if index > length {
            return self + string
        } else if index < 0 {
            return string + self
        }
        return self[0..<index] + string + self[index..<length]
    }

}
