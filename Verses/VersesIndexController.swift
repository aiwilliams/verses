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
        let cell = tableView.dequeueReusableCellWithIdentifier("verseCell")
        let passage = passages[indexPath.row]
        cell!.textLabel!.text = passage.reference!
        return cell!
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            deletePassageIndexPath = indexPath
            let passageToDelete = passages[indexPath.row]
            confirmDeletionOf(passageToDelete)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "passagePracticeSegue" {
            let destinationViewController = segue.destinationViewController as! VersePracticeController
            let ip: NSIndexPath = self.tableView.indexPathForCell(sender as! UITableViewCell)!
            let passage: UserPassage = self.passages[ip.row]
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