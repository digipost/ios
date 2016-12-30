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
import SingleLineKeyboardResize

class RecipientViewController: UIViewController, UINavigationControllerDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var recipients : [Recipient] = [Recipient]()
    var addedRecipients : [Recipient] = [Recipient]()
    var deletedRecipient: Recipient?

    @IBOutlet weak var undoButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var undoButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("recipients view navigation bar title", comment: "")
        saveBarButtonItem.title = NSLocalizedString("recipients view navigation bar right button save", comment: "Title for bar button item")
                
        tableView.backgroundColor = UIColor(r: 222, g: 224, b: 225)
        tableView.register(UINib(nibName: "RecipientTableViewCell", bundle: nil), forCellReuseIdentifier: "recipientCell")
        tableView.rowHeight = 65.0
        
        searchBar.delegate = self
        searchBar.placeholder = NSLocalizedString("recipients view search bar placeholder", comment: "placeholder text")
        searchBar.returnKeyType = UIReturnKeyType.done
        searchBar.setShowsCancelButton(false, animated: true)
        
        setupKeyboardNotifcationListenerForScrollView(self.tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        undoButtonBottomConstraint.constant = -400
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeKeyboardNotificationListeners()
    }
    
    @IBAction func undoButtonTapped(_ sender: AnyObject) {
        if deletedRecipient != nil {
            addedRecipients.append(deletedRecipient!)
            tableView.reloadData()
            deletedRecipient = nil
            
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.undoButtonBottomConstraint.constant = -100
                self.undoButton.layoutIfNeeded()
            })
        }
    }

    @IBAction func handleSingleTapOnEmptyTableView(_ tap: UIGestureRecognizer) {
        let point = tap.location(in: tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)
        
        if indexPath == nil {
            searchBar.resignFirstResponder()
        }
    }

    @IBAction func didTapSaveBarButtonItem() {
        self.navigationController?.popViewController(animated: true)
    }
}
