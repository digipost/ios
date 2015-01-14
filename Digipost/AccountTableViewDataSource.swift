//
//  AccountTableViewDataSource.swift
//  Digipost
//
//  Created by Henrik Holmsen on 14.01.15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

class AccountTableViewDataSource: NSObject, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    let tableView:UITableView

    private lazy var fetchedResultsController : NSFetchedResultsController = {
        
        // Create and configure a fetch request with the Book entity.
        let fetchRequest = NSFetchRequest(entityName: "Mailbox")
        let managedObjectContext: NSManagedObjectContext = POSModelManager.sharedManager().managedObjectContext
        
        // Order the events by creation date, most recent first.
        let ownerDescriptor = NSSortDescriptor(key: "owner", ascending: true)
        let nameDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [ownerDescriptor,nameDescriptor]
        
        var controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext:managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        
        var error: NSError?
        
        if !controller.performFetch(&error){
            println(error?.localizedDescription)
        }
        
        return controller
        }()
    
    // MARK: - Class initialiser
    
    init(asDataSourceForTableView tableView: UITableView){
        
        self.tableView = tableView
        super.init()
        tableView.dataSource = self
        self.fetchedResultsController.delegate = self
    }
    
    // MARK: - UITableViewDataSource
    
    // Set number of sections in tableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let numOfSections = self.fetchedResultsController.sections?.count{
            return numOfSections
        } else {
            return 0
        }
    }
    
    // Set number of rows in section
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
            return sectionInfo.numberOfObjects
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("mailboxCell", forIndexPath: indexPath)as UITableViewCell
        
        let cell: AccountTableViewCell = tableView.dequeueReusableCellWithIdentifier(Constants.Account.cellIdentifier, forIndexPath: indexPath) as AccountTableViewCell
        self.configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    // Customize the appearance of table view cells.
    func configureCell(cell: AccountTableViewCell, atIndexPath indexPath: NSIndexPath){
        let mailBox: POSMailbox = self.fetchedResultsController.objectAtIndexPath(indexPath) as POSMailbox
       // cell.textLabel?.text = mailBox.name
        cell.accountNameLabel.text = mailBox.name
    }
    
    // convenience method for fetching objects at index path from the database
    func managedObjectAtIndexPath(indexPath: NSIndexPath) -> NSManagedObject{
        return self.fetchedResultsController.objectAtIndexPath(indexPath) as NSManagedObject
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        
        case NSFetchedResultsChangeType.Insert:
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
        case NSFetchedResultsChangeType.Delete:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
        case NSFetchedResultsChangeType.Update:
            let updateCell: AccountTableViewCell = self.tableView.cellForRowAtIndexPath(indexPath!) as AccountTableViewCell
            self.configureCell(updateCell, atIndexPath: indexPath!)
        case NSFetchedResultsChangeType.Move:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        switch type{
        case NSFetchedResultsChangeType.Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Automatic)
        case NSFetchedResultsChangeType.Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Automatic)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }

    
}

