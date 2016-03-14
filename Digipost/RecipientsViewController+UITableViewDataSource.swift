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

extension RecipientViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchBar.isFirstResponder() {
            return self.recipients.count
        } else {
            return self.addedRecipients.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = self.tableView.dequeueReusableCellWithIdentifier("recipientCell") as! RecipientTableViewCell
        
        if searchBar.isFirstResponder() {
            if recipients.count > 0 {
                if let recipient = recipients[indexPath.row] as Recipient? {
                    cell.loadCell(recipient: recipient)
                    for r in addedRecipients {
                        if r.name == recipient.name && r.digipostAddress! == recipients[indexPath.row].digipostAddress! {
                            cell.addedButton.hidden = false
                        }
                    }
                }
            }
        } else {
            if let recipient = addedRecipients[indexPath.row] as Recipient? {
                cell.loadCell(recipient: recipient)
                cell.addedButton.hidden = false
            }
        }
        
        return cell
    }
}

