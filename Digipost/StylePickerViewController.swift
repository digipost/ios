//
//  StylePickerViewController.swift
//  Digipost
//
//  Created by Håkon Bogen on 07/07/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

protocol StylePickerViewControllerDelegate {

    func StylePickerViewControllerDidSelectStyle(stylePickerViewController : StylePickerViewController)

}

class StylePickerViewController: UIViewController, UITableViewDelegate, SegmentedControlTableViewCellDelegate {

    static let storyboardIdentifier = "stylePickerViewController"

    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var segmentedControl : UISegmentedControl!


    var textStyleModels : [[TextStyleModel]] = { TextStyleModel.allTextStyleModels() }()

    func setupForAttributedString(attributedString: NSAttributedString )  {


    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func segmentedControlTableViewCellDidSelectControlAtIndex(segmentedControlTableViewCell: SegmentedControlTableViewCell, indexTapped: Int) {

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
