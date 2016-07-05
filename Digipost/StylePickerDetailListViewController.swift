//
// Copyright (C) Posten Norge AS
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//         http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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

    @IBOutlet var navigationBar : UINavigationBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }

    @IBAction func didTapBackBarButtonItem(sender: UIBarButtonItem) {
        delegate?.stylePickerDetailLIstViewControllerDidTapBackButton(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationBar.barTintColor = UIColor(r: 230, g: 231, b: 233, alpha: 1)
        navigationBar.tintColor = UIColor.blackColor()
        navigationBar.titleTextAttributes = [ NSForegroundColorAttributeName : UIColor.blackColor() ]
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.textStyleModels.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) 
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

