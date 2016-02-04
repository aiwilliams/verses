//
//  VerseSelectController.swift
//  Verses
//
//  Created by Isaac Williams on 2/3/16.
//  Copyright © 2016 The Williams Family. All rights reserved.
//

import Foundation
import UIKit

class VerseSelectController: UITableViewController {
    var passage: UserPassage!
    var selectedVerses: Array<UserVerse> = []

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return passage.verses!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("verseCell") as! VerseCell
        let verse = passage.verses![indexPath.row] as! UserVerse
        cell.versePassageLabel.text = verse.reference
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = self.tableView.cellForRowAtIndexPath(indexPath)
        let verse = passage.verses![indexPath.row] as! UserVerse

        if !selectedVerses.contains(verse) {
            cell!.accessoryType = .Checkmark
            selectedVerses.append(verse)
        } else {
            cell!.accessoryType = .None
            let index = selectedVerses.indexOf(verse)
            selectedVerses.removeAtIndex(index!)
        }
        
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    @IBAction func cancelVerseSelect(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func continueToPractice(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("practiceSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationViewController = segue.destinationViewController as! VersePracticeController
        destinationViewController.verses = NSOrderedSet(array: self.selectedVerses)
    }
}