//
//  ImageModuleTableViewCell.swift
//  ModuleSendEditor
//
//  Created by Henrik Holmsen on 26.02.15.
//  Copyright (c) 2015 Nettbureau AS. All rights reserved.
//

import UIKit

class ImageModuleTableViewCell: UITableViewCell {

    @IBOutlet var moduleImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
