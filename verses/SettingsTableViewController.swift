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

class SettingsTableViewController : UITableViewController, RemindersSwitchSectionDelegate, ReminderFormDelegate {
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
    var remindersList: RemindersListSection {
        get { return sections[1] as RemindersListSection }
    }
    
    func remindersSwitchSet(#on: Bool) {
        remindersOn = on
        let changingSections = sections.filter({ !$0.enabledWhenRemindersOff() })
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier != "ReminderDetailSegue" { return }
        
        let indexPath = tableView.indexPathForSelectedRow()!
        let section = sections[indexPath.section] as RemindersListSection
        let detail = segue.destinationViewController as ReminderDetailViewController
        detail.reminder = section.reminders[indexPath.row]
        detail.delegate = self
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
            self.tableView.beginUpdates()
            remindersList.deleteReminder(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            self.tableView.endUpdates()
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return sections[indexPath.section].isEditable
    }
    
    @IBAction func didAddReminder(sender: AnyObject) {
        let reminder = remindersList.addReminder()
        let indexPath = NSIndexPath(forRow: remindersList.numberOfRows()-1, inSection: 1)
        self.tableView.beginUpdates()
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        self.tableView.endUpdates()
    }
    
    func reminderChanged(reminder: Reminder) {
        managedObjectContext.save(nil)
        self.rebuildNotifications()
    }
    
    func createLocalNotification(reminder: Reminder) -> UILocalNotification {
        let localNotification: UILocalNotification = UILocalNotification()
        localNotification.timeZone = NSTimeZone.defaultTimeZone()
        
        let components = NSCalendar.currentCalendar().components(NSCalendarUnit.HourCalendarUnit, fromDate: reminder.time)
        localNotification.fireDate = NSCalendar.currentCalendar().dateFromComponents(components)
        
        localNotification.repeatInterval = reminder.frequency
        
        let appDelegate = UIApplication.sharedApplication().delegate! as AppDelegate
        if let biblePassage = appDelegate.biblePassageStore.activeBiblePassage() {
            localNotification.alertBody = "\(biblePassage.passage!)"
        }
        else {
            localNotification.alertBody = "You don't have any verses!"
        }
        localNotification.hasAction = true
        localNotification.applicationIconBadgeNumber = localNotification.applicationIconBadgeNumber + 1
        
        return localNotification
    }
    
    func rebuildNotifications() {
        var notifications = [UILocalNotification]()
        for r in remindersList.reminders {
            notifications += [createLocalNotification(r)]
        }
        
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        UIApplication.sharedApplication().scheduledLocalNotifications = notifications
    }

}
