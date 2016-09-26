//
//  UncategorisedReceiptsTableViewCell.swift
//  Digipost
//
//  Created by William Berg on 23/09/16.
//  Copyright © 2016 Posten Norge AS. All rights reserved.
//

import Foundation

class UncategorisedReceiptsTableViewCell : UITableViewCell {
    
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var storeNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    static let identifier = "ReceiptTableViewCellIdentifier"
    static let nibName = "ReceiptTableViewCellNib"
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        self.tintColor = self.editing ? UIColor(colorLiteralRed: 64.0 / 255.0,
            green: 66.0 / 255.0, blue: 69.0 / 255.0, alpha: 1.0)
            : UIColor.whiteColor()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        self.tintColor = self.editing ? UIColor(colorLiteralRed: 64.0 / 255.0,
                                                green: 66.0 / 255.0, blue: 69.0 / 255.0, alpha: 1.0)
            : UIColor.whiteColor()
    }
}