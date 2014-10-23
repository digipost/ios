//
//  UIToolbar+Actions.swift
//  Digipost
//
//  Created by Håkon Bogen on 23/10/14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

import UIKit

extension UIToolbar {
    
    
    func setupIconsForLetterViewController(letterViewController: POSLetterViewController){
//        backgroundColor = UIColor.whiteColor()
//        tintColor = UIColor.whiteColor()
        barTintColor = UIColor.whiteColor()
        let items = NSMutableArray()
        
        setItems(items, animated: false)
    }
 
}
