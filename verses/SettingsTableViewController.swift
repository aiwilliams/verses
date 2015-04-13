//
//  SettingsTableViewController.swift
//  verses
//
//  Created by Isaac Williams on 11/4/14.
//  Copyright (c) 2014 The Williams Family. All rights reserved.
//

import UIKit
import CoreData

// MARK: Extensions

extension Array {
    func sample() -> T {
        let randomIndex = random() % count
        return self[randomIndex]
    }
}

class SettingsTableViewController : UITableViewController,
    RemindersSwitchSectionViewDelegate,
    RemindersAddSectionViewDelegate {
    
    // MARK: Variable and constant declarations
    
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    lazy var managedObjectContext: NSManagedObjectContext = { self.appDelegate.managedObjectContext }()
    
    var sections: [SettingsSectionViewController] = []
    var reminders: [Reminder] = []
    
    var switchSection: RemindersSwitchSectionViewController {
        get { return sections[0] as! RemindersSwitchSectionViewController }
    }
    
    // MARK: Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sections  = [
            RemindersSwitchSectionViewController(delegate: self),
            RemindersAddSectionViewController(delegate: self)
        ]
        loadRemindersSections()
    }
    
    // MARK: Custom section methods
    
    func remindersSwitchDidChange(on: Bool) {
        let changingSections = sections.filter({ !$0.enabledWhenRemindersOff })
        let indexRange = NSIndexSet(indexesInRange: NSMakeRange(1, changingSections.count))
        
        self.tableView.beginUpdates()

        if on == true {
            self.tableView.insertSections(indexRange, withRowAnimation: .Fade)
            self.rebuildNotifications()
        } else {
            self.tableView.deleteSections(indexRange, withRowAnimation: .Fade)
            UIApplication.sharedApplication().cancelAllLocalNotifications()
        }
        
        self.tableView.endUpdates()
    }
    
    func addReminder(section: RemindersAddSectionViewController) {
        // TODO: Schedule reminder for added reminder
        let indexBeforeAddSection = sections.count-1
        let reminderSection = ReminderSectionViewController(managedObjectContext: self.managedObjectContext, reminder: nil)
        sections.insert(reminderSection, atIndex: indexBeforeAddSection)
        self.tableView.insertSections(NSIndexSet(index: indexBeforeAddSection), withRowAnimation: .Fade)
    }
    
    func loadRemindersSections() {
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = Reminder.entity(managedObjectContext)
        
        var error: NSError?
        reminders = managedObjectContext.executeFetchRequest(fetchRequest, error: &error)! as! [Reminder]
        if error != nil {
            println("Fetch error: \(error)")
        }
        
        var i = 1
        for r in reminders {
            sections.insert(ReminderSectionViewController(managedObjectContext: managedObjectContext, reminder: r), atIndex: i)
            i++
        }
    }
    
    // MARK: Table view methods
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.switchSection.on ? sections.count : sections.filter({ $0.enabledWhenRemindersOff }).count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(sections[indexPath.section].heightForRow(indexPath.row))
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].numberOfRows()
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        return section.tableView(tableView, cellForRow: indexPath.row)
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return sections[indexPath.section].isEditable
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            self.tableView.beginUpdates()
            let reminderSection = sections[indexPath.section] as! ReminderSectionViewController
            reminderSection.deleteReminder()
            sections.removeAtIndex(indexPath.section)
            rebuildNotifications()
            tableView.deleteSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Fade)
            self.tableView.endUpdates()
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        sections[indexPath.section].tableView(tableView, didSelectRow: indexPath.row)

        // tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    // MARK: UILocalNotification management
    
    let reminderNotificationMessages: [String] = [
        "Whatever you're doing is not as important as the Bible.",
        "God wants YOU! (to memorize the Bible)",
        "You haven't studied your verses in a while...",
        "People who memorize the Bible are scientifically proven to be fabulous-er... That is a word, right?",
        "Just in case you forgot, here's a friendly reminder - MEMORIZE THE BIBLE!",
        "The Bible is awesome, you should probably memorize it.",
        "Are you sad? Memorizing the Bible will lift your spirits!"
    ]
    
    func reminderChanged(reminder: Reminder) {
        managedObjectContext.save(nil)
        self.rebuildNotifications()
        self.tableView.reloadData()
    }
    
    func rebuildNotifications() {
        if sections.count > 2 {
            var notifications = [UILocalNotification]()
            let reminderLists = sections[1...sections.count-2]
            for section in reminderLists {
                let reminderSection = section as! ReminderSectionViewController
                notifications += [createLocalNotification(reminderSection.reminder)]
            }
            UIApplication.sharedApplication().scheduledLocalNotifications = notifications
        }
    }
    
    func createLocalNotification(reminder: Reminder) -> UILocalNotification {
        var alertBody: String = reminderNotificationMessages.sample()
        return ReminderNotification(reminder: reminder, alertBody: alertBody)
    }

}
