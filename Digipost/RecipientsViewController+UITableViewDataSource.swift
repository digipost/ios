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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchBar.isFirstResponder {
            return self.recipients.count
        } else {
            return self.addedRecipients.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "recipientCell") as! RecipientTableViewCell
        
        if searchBar.isFirstResponder {
            if recipients.count > 0 {
                if let recipient = recipients[indexPath.row] as Recipient? {
                    cell.loadCell(recipient: recipient)
                    for r in addedRecipients {
                        if r.name == recipient.name && r.digipostAddress! == recipients[indexPath.row].digipostAddress! {
                            cell.addedButton.isHidden = false
                        }
                    }
                }
            }
        } else {
            if let recipient = addedRecipients[indexPath.row] as Recipient? {
                cell.loadCell(recipient: recipient)
                cell.addedButton.isHidden = false
            }
        }
        
        return cell
    }
}

