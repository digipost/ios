//
//  FontPickerViewController.swift
//  Digipost
//
//  Created by Håkon Bogen on 04/05/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

protocol FontPickerViewControllerDelegate {
    func fontPickerViewController(fontPickerViewController : FontPickerViewController, didSelectFont font: UIFont)
}

class FontPickerViewController: UITableViewController {

    let fonts = UIFont.commonWebFonts()
    var delegate : FontPickerViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "FontPickerTableViewCell", bundle: NSBundle.mainBundle())
        tableView.registerNib(nib, forCellReuseIdentifier: "cell")
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let font = fonts[indexPath.row]
        delegate?.fontPickerViewController(self, didSelectFont: font)
    }

}
