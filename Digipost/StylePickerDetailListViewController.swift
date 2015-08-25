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
    func stylePickerDetailLIstViewControllerDidSelectTextStyleModel(stylePickerDetailListViewController: StylePickerDetailListViewController, textStyleModel: TextStyleModel)

}

class StylePickerDetailListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var textStyleModels : [TextStyleModel]!

    var delegate : StylePickerDetailListViewControllerDelegate?

    @IBOutlet var tableView : UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
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
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell
        let textStyleModel = textStyleModels[indexPath.row]
        if let actualName = textStyleModel.name {
            cell.textLabel?.text = actualName
        } else {
            cell.textLabel?.text = textStyleModel.keyword
        }

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let textStyleModel = textStyleModels[indexPath.row]
        textStyleModels.setTextStyleModelEnabledAndAllOthersDisabled(textStyleModel)
        delegate?.stylePickerDetailLIstViewControllerDidSelectTextStyleModel(self, textStyleModel: textStyleModel)

    }
}

