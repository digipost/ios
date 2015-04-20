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
    @IBOutlet weak var textView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    @IBAction func alignContentLeft(sender: AnyObject) {
        println(textView.text)
    }
    
    @IBAction func alignContentCenter(sender: AnyObject) {

    }

    @IBAction func alignContentRight(sender: AnyObject) {

    }
}
