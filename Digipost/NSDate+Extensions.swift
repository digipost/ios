//
//  NSDate+Extensions.swift
//  Digipost
//
//  Created by Håkon Bogen on 07/11/14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

import UIKit

extension NSDate {
    
    func prettyStringWithJPGExtension()-> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd MMM YY hh:mm:ss"
        var dateString = dateFormatter.stringFromDate(self)
        dateString = dateString.stringByAddingPercentEscapesUsingEncoding(NSASCIIStringEncoding)!
        dateString = dateString.stringByAppendingString(".jpg")
        return dateString
    }
}
