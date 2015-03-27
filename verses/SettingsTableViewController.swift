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
    var delegate: ReminderFormDelegate! { get set }
}

extension Array {
    func sample() -> T {
        let randomIndex = random() % count
        return self[randomIndex]
    }
}

class SettingsTableViewController : UITableViewController, RemindersSwitchSectionDelegate, RemindersAddSectionDelegate, ReminderFormDelegate {
    var remindersOn = true
    
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    let reminderNotificationMessages: [String] = [
        "Whatever you're doing is not as important as the Bible.",
        "God wants YOU! (to memorize the Bible)",
        "You haven't studied your verses in a while... but it's whatever.",
        "People who memorize the Bible are way more fabulous."
    ]

    lazy var managedObjectContext: NSManagedObjectContext = { self.appDelegate.managedObjectContext }()
    lazy var sections: [SettingsSection] = {
        return [
            RemindersSwitchSection(delegate: self, switchOn: true),
            RemindersListSection(managedObjectContext: self.managedObjectContext),
            RemindersAddSection(delegate: self)
        ]
    }()
    var remindersList: RemindersListSection {
        get { return sections[1] as RemindersListSection }
    }
    
    func remindersSwitchSection(section: RemindersSwitchSection, setSwitchOn on: Bool) {
        remindersOn = on
        let changingSections = sections.filter({ !$0.enabledWhenRemindersOff })
        let indexRange = NSIndexSet(indexesInRange: NSMakeRange(1, changingSections.count))
        
        self.tableView.beginUpdates()

        if remindersOn {
            self.tableView.insertSections(indexRange, withRowAnimation: .Fade)
            self.rebuildNotifications()
        } else {
            self.tableView.deleteSections(indexRange, withRowAnimation: .Fade)
            UIApplication.sharedApplication().cancelAllLocalNotifications()
        }
        
        self.tableView.endUpdates()
    }
    
    func addReminder(section: RemindersAddSection) {
        let reminder = remindersList.addReminder()
        let indexPath = NSIndexPath(forRow: remindersList.numberOfRows()-1, inSection: 1)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier != "ReminderDetailSegue" { return }
        
        let indexPath = tableView.indexPathForSelectedRow()!
        let section = sections[indexPath.section] as RemindersListSection
        let detail = segue.destinationViewController as ReminderDetailViewController
        detail.reminder = section.reminders[indexPath.row]
        detail.delegate = self
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.remindersOn ? sections.count : sections.filter({ $0.enabledWhenRemindersOff }).count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].numberOfRows()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        let identifier = section.reuseIdentifier
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier) as UITableViewCell
        section.configureCell(cell, atIndex: indexPath.row)
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            self.tableView.beginUpdates()
            remindersList.deleteReminder(indexPath.row)
            rebuildNotifications()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            self.tableView.endUpdates()
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return sections[indexPath.section].isEditable
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.sections[indexPath.section].selectRow(atIndex: indexPath.row)
    }
    
    func reminderChanged(reminder: Reminder) {
        managedObjectContext.save(nil)
        self.rebuildNotifications()
        self.tableView.reloadData()
    }
    
    func rebuildNotifications() {
        var notifications = [UILocalNotification]()
        for r in remindersList.reminders {
            notifications += [createLocalNotification(r)]
        }
        
        UIApplication.sharedApplication().scheduledLocalNotifications = notifications
    }
    
    func createLocalNotification(reminder: Reminder) -> UILocalNotification {
        var alertBody: String = reminderNotificationMessages.sample()
        return ReminderNotification(reminder: reminder, alertBody: alertBody)
    }

}
