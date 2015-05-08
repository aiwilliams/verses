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
    var _orderedPassages: [BiblePassage]?

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
    
    // MARK: Custom methods
    
    func orderedPassages() -> [BiblePassage] {
        if _orderedPassages == nil { _orderedPassages = self.fetchedResultsController.fetchedObjects as? [BiblePassage] }
        let activePassage = self.appDelegate.biblePassageStore.activeBiblePassage
        
        if activePassage == nil { return _orderedPassages! }
        
        let otherPassages = _orderedPassages!.filter {$0 != activePassage}
        _orderedPassages = [activePassage!] + otherPassages
        
        return _orderedPassages!
    }
    
    func flagCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let activePassage = orderedPassages()[indexPath.row] == self.appDelegate.biblePassageStore.activeBiblePassage
        cell.accessoryView = activePassage ? UIImageView(image: UIImage(named: "flag.png")) : nil
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
        let passage: BiblePassage = self.orderedPassages()[indexPath.row]
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("verseCell", forIndexPath: indexPath) as! UITableViewCell
        if passage.passage != nil { cell.textLabel!.text = passage.passage }
//        flagCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        let passage = self.orderedPassages()[indexPath.row]
        var actions = [UITableViewRowAction]()
        
        let deleteAction = UITableViewRowAction(style: .Normal, title: "Delete", handler: { (action: UITableViewRowAction!, indexPath: NSIndexPath!) in
            self.managedObjectContext?.deleteObject(passage)
            self.managedObjectContext?.save(nil)
        })
        
        deleteAction.backgroundColor = UIColor.redColor()
        actions.append(deleteAction)

        if orderedPassages()[indexPath.row] != self.appDelegate.biblePassageStore.activeBiblePassage {
            let flagAction = UITableViewRowAction(style: .Normal, title: "Flag", handler: { (action: UITableViewRowAction!, indexPath: NSIndexPath!) in
                self.appDelegate.exportToTodayApp(passage)
                self.appDelegate.biblePassageStore.activeBiblePassage = self.orderedPassages()[indexPath.row]
                
                let topIndexPath = NSIndexPath(forRow: 0, inSection: 0)
                //            tableView.reloadRowsAtIndexPaths([indexPath, topIndexPath], withRowAnimation: .None)
                
                tableView.moveRowAtIndexPath(indexPath, toIndexPath: topIndexPath)
                tableView.editing = false
            })
            flagAction.backgroundColor = UIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0)
            actions.append(flagAction)
        }
        
        return actions
    }
    
    // MARK: Segue Control

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "verseDetail" {
            let detailController: VerseDetailTableViewController = segue.destinationViewController as! VerseDetailTableViewController
            detailController.biblePassage = self.orderedPassages()[self.tableView.indexPathForSelectedRow()!.row]
        }
    }
    
    func addVerseCanceled() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func verseAdded(passage: BiblePassage) {
        self.appDelegate.biblePassageStore.activeBiblePassage = passage
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