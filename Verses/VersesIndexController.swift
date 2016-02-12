//
//  VersesIndexController.swift
//  Verses
//
//  Created by Isaac Williams on 11/12/15.
//  Copyright © 2015 The Williams Family. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class VersesIndexController: UITableViewController {
    var passages = [UserPassage]()
    var deletePassageIndexPath: NSIndexPath!
    var selectPassageIndexPath: NSIndexPath!
    var selectedVerses: [UserVerse]!
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let moc = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "UserPassage")
        
        do {
            let results = try moc.executeFetchRequest(fetchRequest)
            passages = results as! [UserPassage]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return passages.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("passageCell") as! PassageCell
        let passage = passages[indexPath.row]
        cell.titleLabel.text = passage.reference
        if passage.memorized!.boolValue {
            cell.flagLabel.text = "⚑"
        } else {
            cell.flagLabel.text = "⚐"
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! PassageCell
        let passage = self.passages[indexPath.row]
        
        let selectAction = UITableViewRowAction(style: .Normal, title: "Select", handler: { (action: UITableViewRowAction!, indexPath: NSIndexPath!) in
            self.selectPassageIndexPath = indexPath
            let destination = self.storyboard!.instantiateViewControllerWithIdentifier("selectVerses") as! VerseSelectController
            let navigationController = UINavigationController(rootViewController: destination)
            destination.passage = passage
            destination.dismissalHandler = { (verses: Array<UserVerse>) -> Void in
                self.selectedVerses = verses
                self.performSegueWithIdentifier("passagePracticeSegue", sender: self)
            }
            self.presentViewController(navigationController, animated: true, completion: nil)
        })

        var memorizeAction: UITableViewRowAction!
        if passage.memorized!.boolValue {
            memorizeAction = UITableViewRowAction(style: .Normal, title: "Start over", handler: { (action: UITableViewRowAction!, indexPath: NSIndexPath!) in
                passage.memorized = false
                try! self.appDelegate.managedObjectContext.save()
                cell.flagLabel.text = "⚐"
                tableView.setEditing(false, animated: true)
            })
        } else {
            memorizeAction = UITableViewRowAction(style: .Normal, title: "Memorize", handler: { (action: UITableViewRowAction!, indexPath: NSIndexPath!) in
                passage.memorized = true
                try! self.appDelegate.managedObjectContext.save()
                cell.flagLabel.text = "⚑"
                tableView.setEditing(false, animated: true)
            })
        }
        memorizeAction.backgroundColor = UIColor(red:0.27, green:0.83, blue:0.55, alpha:1.0)
        
        let deleteAction = UITableViewRowAction(style: .Normal, title: "Delete", handler: { (action: UITableViewRowAction!, indexPath: NSIndexPath!) in
            self.deletePassageIndexPath = indexPath
            let passageToDelete = self.passages[indexPath.row]
            self.confirmDeletionOf(passageToDelete)
        })
        deleteAction.backgroundColor = UIColor(red:1.00, green:0.35, blue:0.31, alpha:1.0)
        
        if passage.verses!.count != 1 {
            return [deleteAction, memorizeAction, selectAction]
        } else {
            return [deleteAction, memorizeAction]
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "passagePracticeSegue" {
            let destinationViewController = segue.destinationViewController as! VersePracticeController
            var ip: NSIndexPath = NSIndexPath()
            
            if selectPassageIndexPath == nil {
                ip = self.tableView.indexPathForCell(sender as! UITableViewCell)!
            } else {
                ip = selectPassageIndexPath
            }
            
            let passage: UserPassage = self.passages[ip.row]
            
            if selectedVerses == nil {
                destinationViewController.verses = passage.verses!
            } else {
                destinationViewController.verses = NSOrderedSet(array: self.selectedVerses)
            }
        } else if segue.identifier == "verseSelectSegue" {
            let destinationNavController = segue.destinationViewController as! UINavigationController
            let destinationViewController = destinationNavController.topViewController as! VerseSelectController
            let passage: UserPassage = self.passages[selectPassageIndexPath.row]
            destinationViewController.passage = passage
        }
    }
    
    func confirmDeletionOf(passage: UserPassage) {
        let alert = UIAlertController(title: "Delete Passage", message: "Are you sure you want to delete \(passage.reference!)? This will permanently destroy any practice data!", preferredStyle: .ActionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete, and I mean it!", style: .Destructive, handler: deletePassage)
        let cancelAction = UIAlertAction(title: "Nevermind", style: .Cancel, handler: cancelDeletePassage)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func deletePassage(alertAction: UIAlertAction!) {
        if let ip = deletePassageIndexPath {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.managedObjectContext.deleteObject(passages[ip.row])
            
            do {
                try appDelegate.managedObjectContext.save()
            } catch let err as NSError {
                print("Couldn't delete a passage. Error: \(err), \(err.userInfo)")
            }

            tableView.beginUpdates()

            passages.removeAtIndex(ip.row)
            tableView.deleteRowsAtIndexPaths([ip], withRowAnimation: .Automatic)
            deletePassageIndexPath = nil

            tableView.endUpdates()
        }
    }
    
    func cancelDeletePassage(alertAction: UIAlertAction!) {
        deletePassageIndexPath = nil
    }
}