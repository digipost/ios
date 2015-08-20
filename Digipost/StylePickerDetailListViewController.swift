//
//  StylePickerDetailListViewController.swift
//  Digipost
//
//  Created by Håkon Bogen on 18/08/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

protocol StylePickerDetailListViewControllerDelegate {

    func stylePickerDetailLIstViewControllerDidTapBackButton(stylePickerDetailListViewController: StylePickerDetailListViewController)
}

class StylePickerDetailListViewController: UIViewController, UITableViewDataSource {

    var textStyleModels : [TextStyleModel]!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.textStyleModels.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        return tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell

//        let arrayOfModels = self.textStyleModels[indexPath.row]
//        let cell : UITableViewCell = {
//            if arrayOfModels.count == 1 {
//                // single choice type cell
//            } else {
//                // multi select type cell
//                let firstObject = arrayOfModels.first!
//                    if firstObject.value is UIFont {
//                        let cell =  tableView.dequeueReusableCellWithIdentifier("pickerCell", forIndexPath: indexPath) as! UITableViewCell
//                        return cell
//                    } else {
//                        let cell =  tableView.dequeueReusableCellWithIdentifier("segmentedControlCell", forIndexPath: indexPath) as! SegmentedControlTableViewCell
//                        cell.delegate = self
//                        for (index, model) in enumerate(arrayOfModels) {
//                            cell.multiselectSegmentedControl.setButtonSelectedState(model.enabled, atIndex: index)
//                        }
//                        return cell
//
//                }
//            }
//            }()
//        return cell
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
