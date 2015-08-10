//
//  Array+NSRange.swift
//  Digipost
//
//  Created by Håkon Bogen on 10/08/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

extension Array {
    // worst case O(n)
    func contains(range: NSRange) -> Bool {
        for object in self {
            if let aRange = object as? NSRange {
                if aRange.location == range.location && aRange.length == range.length {
                    return true
                }
            }
        }
        return false
    }
}
