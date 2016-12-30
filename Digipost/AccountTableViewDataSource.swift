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

class AccountTableViewDataSource: NSObject, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    let tableView:UITableView
    
    lazy var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult> = {
        
        // Create and configure a fetch request with the Mailbox entity.
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Mailbox")
        let managedObjectContext: NSManagedObjectContext = POSModelManager.shared().managedObjectContext
        
        // Order the events by creation date, most recent first.
        let ownerDescriptor = NSSortDescriptor(key: "owner", ascending: false)
        let nameDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [ownerDescriptor,nameDescriptor]
        
        var controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext:managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try controller.performFetch()
        } catch let error {
            print(error)
        }
        
        return controller
    }()
    
    // MARK: - Class initialiser
    
    init(asDataSourceForTableView tableView: UITableView){
        self.tableView = tableView
        super.init()
        tableView.dataSource = self
        fetchedResultsController.delegate = self
    }
    
    func startListeningToCoreDataChanges() {
        self.fetchedResultsController.delegate = self
    }
    
    func stopListeningToCoreDataChanges() {
        self.fetchedResultsController.delegate = nil
    }
    // MARK: - UITableViewDataSource
    
    // Set number of sections in tableView
    func numberOfSections(in tableView: UITableView) -> Int {
        if let numOfSections = self.fetchedResultsController.sections?.count{
            return numOfSections
        } else {
            return 0
        }
    }
    
    // Set number of rows in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell?
        
        let mailBox = fetchMailBox(atIndexPath: indexPath)
        
        if mailBox.owner == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: Constants.Account.accountCellIdentifier, for: indexPath) as! AccountTableViewCell
            
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: Constants.Account.mainAccountCellIdentifier, for: indexPath) as! MainAccountTableViewCell
        }
        
        self.configureCell(cell!, atIndexPath: indexPath, mailBox: mailBox)
        
        return cell!
        
    }
    
    // Customize the appearance of table view cells.
    func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath, mailBox: POSMailbox){
                
        var unreadItemsString = ""
        if let unreadItems = mailBox.unreadItemsInInbox {
            var str = ""
            if unreadItems == 1{
                str = NSLocalizedString("account view unread letter", comment: "Unread message")
                unreadItemsString = "\(unreadItems)\(str)"
            } else {
                str = NSLocalizedString("account view unread letters", comment: "Unread messages")
                unreadItemsString = "\(unreadItems) \(str)"
            }
        }
        
        if let accountCell = cell as? AccountTableViewCell {
            accountCell.accountNameLabel.text = mailBox.name
            accountCell.initialLabel.text = mailBox.name.initials()
            accountCell.unreadMessages.text = unreadItemsString
            accountCell.accountDescriptionLabel.text = NSLocalizedString("account description shared", comment: "Shared with you")
            
        } else if let mainAccountCell = cell as? MainAccountTableViewCell {
            mainAccountCell.accountNameLabel.text = mailBox.name
            mainAccountCell.initialLabel.text = mailBox.name.initials()
            mainAccountCell.unreadMessages.text = unreadItemsString
        }
    }
    
    // Convenience method for getteing the mailbox at an Indexpath in tableview
    func fetchMailBox(atIndexPath indexPath: IndexPath) -> POSMailbox{
        return self.fetchedResultsController.object(at: indexPath) as! POSMailbox
    }
    
    // convenience method for fetching objects at index path from the database
    func managedObjectAtIndexPath(_ indexPath: IndexPath) -> NSManagedObject{
        return self.fetchedResultsController.object(at: indexPath) as! NSManagedObject
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
            
        case NSFetchedResultsChangeType.insert:
            self.tableView.insertRows(at: [newIndexPath!], with: UITableViewRowAnimation.fade)
        case NSFetchedResultsChangeType.delete:
            self.tableView.deleteRows(at: [indexPath!], with: UITableViewRowAnimation.fade)
        case NSFetchedResultsChangeType.update:
            let updateCell = self.tableView.cellForRow(at: indexPath!)
            self.configureCell(updateCell!, atIndexPath: indexPath!, mailBox: self.fetchMailBox(atIndexPath: indexPath!))
        case NSFetchedResultsChangeType.move:
            self.tableView.deleteRows(at: [indexPath!], with: UITableViewRowAnimation.fade)
            self.tableView.insertRows(at: [newIndexPath!], with: UITableViewRowAnimation.fade)
        }
        
        Badge.setCombinedUnreadLettersBadge(fetchedResultsController.fetchedObjects as! [POSMailbox])
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        switch type{
        case NSFetchedResultsChangeType.insert:
            self.tableView.insertSections(IndexSet(integer: sectionIndex), with: UITableViewRowAnimation.automatic)
        case NSFetchedResultsChangeType.delete:
            self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: UITableViewRowAnimation.automatic)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
}

