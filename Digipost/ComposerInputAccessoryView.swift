//
//  ComposerInputAccessoryView.swift
//  Digipost
//
//  Created by Hannes Waller on 2015-04-16.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

class ComposerInputAccessoryView: UIView {

    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func alignLeft(sender: AnyObject) {
        println("clicking left")
    }
    
    @IBAction func alignCenter(sender: AnyObject) {
        println("clicking center")
    }

    @IBAction func alignRight(sender: AnyObject) {
        println("clicking right")
    }
}
