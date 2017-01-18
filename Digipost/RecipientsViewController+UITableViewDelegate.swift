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

extension RecipientViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var found = false
        
        if searchBar.isFirstResponder {
            for (index, r) in addedRecipients.enumerated() {
                if r.digipostAddress == recipients[indexPath.row].digipostAddress {
                    let cell = tableView.cellForRow(at: indexPath) as! RecipientTableViewCell
                    cell.addedButton.isHidden = true
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "deleteRecipientNotification"), object: r, userInfo: nil)
                    addedRecipients.remove(at: index)
                    tableView.reloadData()
                    found = true
                }
            }
            if found == false {
                addedRecipients.append(recipients[indexPath.row])
                NotificationCenter.default.post(name: Notification.Name(rawValue: "addRecipientNotification"), object: recipients[indexPath.row], userInfo: nil)
            }
        } else {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "deleteRecipientNotification"), object: addedRecipients[indexPath.row], userInfo: nil)
            deletedRecipient = addedRecipients[indexPath.row]
            addedRecipients.remove(at: indexPath.row)
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.undoButtonBottomConstraint.constant = 20
                self.undoButton.layoutIfNeeded()
            })
        }
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect.zero)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(RecipientViewController.handleSingleTapOnEmptyTableView))
        
        singleTap.numberOfTapsRequired = 1
        singleTap.cancelsTouchesInView = false
        tableView.addGestureRecognizer(singleTap)
        
        return footerView
    }
}
