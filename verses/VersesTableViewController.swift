//
//  VersesTableViewController.swift
//  verses
//
//  Created by Isaac Williams on 1/31/15.
//  Copyright (c) 2015 The Williams Family. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class VersesTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, AddVerseDelegate {
    // MARK: Variable and constant declaration
    
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var managedObjectContext: NSManagedObjectContext?

    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("BiblePassage", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity!

        let numberDescriptor = NSSortDescriptor(key: "passage", ascending: true)
        let sortDescriptors = [numberDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self

        return fetchedResultsController
    }()
    
    // MARK: Setup

    override func viewDidLoad() {
        self.tableView.allowsMultipleSelectionDuringEditing = false
        self.managedObjectContext = self.appDelegate.managedObjectContext
        self.fetchedResultsController.performFetch(nil)
    }
    
    // MARK: Table View methods

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        let tableView: UITableView = self.tableView

        switch type {
        case NSFetchedResultsChangeType.Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
        case NSFetchedResultsChangeType.Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
        default:
            break
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        default:
            break
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections!.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo: NSFetchedResultsSectionInfo = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let passage: BiblePassage = self.fetchedResultsController.objectAtIndexPath(indexPath) as! BiblePassage
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("verseCell", forIndexPath: indexPath) as! UITableViewCell
        if passage.passage != nil { cell.textLabel!.text = passage.passage }
        return cell
    }

    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        let editAction = UITableViewRowAction(style: .Normal, title: "Today", handler: { (action: UITableViewRowAction!, indexPath: NSIndexPath!) in
            self.appDelegate.exportToTodayApp(self.fetchedResultsController.objectAtIndexPath(indexPath) as! BiblePassage)
            tableView.cellForRowAtIndexPath(indexPath)!.setEditing(false, animated: true)
        })
        editAction.backgroundColor = UIColor.greenColor()
        
        let deleteAction = UITableViewRowAction(style: .Normal, title: "Delete", handler: { (action: UITableViewRowAction!, indexPath: NSIndexPath!) in
            let passage: BiblePassage = self.fetchedResultsController.objectAtIndexPath(indexPath) as! BiblePassage
            self.managedObjectContext?.deleteObject(passage)
            self.managedObjectContext?.save(nil)
        })
        deleteAction.backgroundColor = UIColor.redColor()
        
        return [deleteAction, editAction]
    }
    
    // MARK: Segue Control

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "verseDetail" {
            let detailController: VerseDetailTableViewController = segue.destinationViewController as! VerseDetailTableViewController
            detailController.biblePassage = self.fetchedResultsController.objectAtIndexPath(self.tableView.indexPathForSelectedRow()!) as? BiblePassage
        }
    }
    
    func addVerseCanceled() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func verseAdded() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func addVerse(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let addVerseNavigationController = storyboard.instantiateViewControllerWithIdentifier("addVerse") as! UINavigationController
        addVerseNavigationController.modalTransitionStyle = .CoverVertical
        let addVerseController = addVerseNavigationController.childViewControllers[0] as! AddVerseViewController
        addVerseController.delegate = self
        self.presentViewController(addVerseNavigationController, animated: true, completion: nil)
    }
    
}