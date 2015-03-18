//
//  SettingsTableViewController.swift
//  verses
//
//  Created by Isaac Williams on 11/4/14.
//  Copyright (c) 2014 The Williams Family. All rights reserved.
//

import UIKit
import CoreData

@objc protocol ReminderForm {
    var reminder: Reminder! { get set }
}

class SettingsTableViewController : UITableViewController, RemindersSwitchSectionDelegate {
    var remindersOn = true
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    lazy var managedObjectContext: NSManagedObjectContext = { self.appDelegate.managedObjectContext }()
    lazy var sections: [SettingsSection] = {
        return [
            RemindersSwitchSection(delegate: self, switchOn: true),
            RemindersListSection(managedObjectContext: self.managedObjectContext),
            RemindersAddSection()
        ]
    }()
    
    func remindersSwitchSet(#on: Bool) {
        remindersOn = on
        let changingSections = sections.filter({ !$0.enabledWhenRemindersOff() })
        let indexRange = NSIndexSet(indexesInRange: NSMakeRange(1, changingSections.count))
        
        self.tableView.beginUpdates()

        if remindersOn {
            self.tableView.insertSections(indexRange, withRowAnimation: .Fade)
        } else {
            self.tableView.deleteSections(indexRange, withRowAnimation: .Fade)
        }
        
        self.tableView.endUpdates()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier != "ReminderDetailSegue" { return }
        
        let detail = segue.destinationViewController as ReminderDetailViewController
        
        let indexPath = tableView.indexPathForSelectedRow()!
        let section = sections[indexPath.section] as RemindersListSection
        let reminderForm = segue.destinationViewController as ReminderForm
        reminderForm.reminder = section.reminders[indexPath.row]
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.remindersOn ? sections.count : sections.filter({ $0.enabledWhenRemindersOff() }).count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].numberOfRows()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        let identifier = section.reuseIdentifier()
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier) as UITableViewCell
        section.configureCell(cell, atIndex: indexPath.row)
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let remindersListSection = sections[1] as RemindersListSection
            self.tableView.beginUpdates()
            remindersListSection.deleteReminder(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            self.tableView.endUpdates()
        }
    }
    
    @IBAction func didAddReminder(sender: AnyObject) {
        let remindersListSection = sections[1] as RemindersListSection
        remindersListSection.addReminder()
        let indexPath = NSIndexPath(forRow: remindersListSection.numberOfRows()-1, inSection: 1)
        self.tableView.beginUpdates()
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        self.tableView.endUpdates()
    }
}
