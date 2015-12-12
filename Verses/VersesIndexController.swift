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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "passagePracticeSegue" {
            let destinationViewController = segue.destinationViewController as! VersePracticeController
            let ip: NSIndexPath = self.tableView.indexPathForCell(sender as! UITableViewCell)!
            let passage: UserPassage = self.passages[ip.row]
            destinationViewController.passage = passage
        }
    }
}