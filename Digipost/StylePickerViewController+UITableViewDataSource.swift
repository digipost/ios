//
//  StylePickerViewController+UITableViewDataSource.swift
//  Digipost
//
//  Created by Håkon Bogen on 07/07/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

extension StylePickerViewController : UITableViewDataSource {



    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.textStyleModels.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let arrayOfModels = self.textStyleModels[indexPath.row]
        let cell : UITableViewCell = {
            if arrayOfModels.count == 1 {
                // single choice type cell
                return tableView.dequeueReusableCellWithIdentifier("", forIndexPath: indexPath) as! UITableViewCell
            } else {
                // multi select type cell
                let firstObject = arrayOfModels.first!
                    if firstObject.value is UIFont {
                        let cell =  tableView.dequeueReusableCellWithIdentifier("pickerCell", forIndexPath: indexPath) as! UITableViewCell
                        return cell
                    } else {
                        let cell =  tableView.dequeueReusableCellWithIdentifier("segmentedControlCell", forIndexPath: indexPath) as! SegmentedControlTableViewCell
                        cell.delegate = self
                        for (index, model) in enumerate(arrayOfModels) {
                            cell.multiselectSegmentedControl.setButtonSelectedState(model.enabled, atIndex: index)
                        }
                        return cell

                }
            }
            }()
        return cell
    }
}
