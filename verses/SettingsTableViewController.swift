//
//  SettingsTableViewController.swift
//  verses
//
//  Created by Isaac Williams on 11/4/14.
//  Copyright (c) 2014 The Williams Family. All rights reserved.
//

import UIKit
import CoreData

// MARK: Protocols

@objc protocol ReminderForm {
    var reminder: Reminder! { get set }
    var delegate: ReminderFormDelegate! { get set }
}

// MARK: Extensions

extension Array {
    func sample() -> T {
        let randomIndex = random() % count
        return self[randomIndex]
    }
}

class SettingsTableViewController : UITableViewController,
    RemindersSwitchSectionViewDelegate,
    RemindersAddSectionViewDelegate,
    ReminderFormDelegate {
    
    // MARK: Variable and constant declarations
    
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    let reminderNotificationMessages: [String] = [
        "Whatever you're doing is not as important as the Bible.",
        "God wants YOU! (to memorize the Bible)",
        "You haven't studied your verses in a while...",
        "People who memorize the Bible are scientifically proven to be fabulous-er... That is a word, right?",
        "Just in case you forgot, here's a friendly reminder - MEMORIZE THE BIBLE!",
        "The Bible is awesome, you should probably memorize it.",
        "Are you sad? Memorizing the Bible will lift your spirits!"
    ]

    lazy var managedObjectContext: NSManagedObjectContext = { self.appDelegate.managedObjectContext }()
    var sections: [SettingsSectionViewController] = []
    var reminders: [Reminder] = []
    
    var switchSection: RemindersSwitchSection {
        get { return sections[0] as RemindersSwitchSection }
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
    
    func remindersSwitchSection(section: RemindersSwitchSection, toggled: Bool) {
        let changingSections = sections.filter({ !$0.enabledWhenRemindersOff })
        let indexRange = NSIndexSet(indexesInRange: NSMakeRange(1, changingSections.count))
        
        self.tableView.beginUpdates()

        if toggled == true {
            self.tableView.insertSections(indexRange, withRowAnimation: .Fade)
            self.rebuildNotifications()
        } else {
            self.tableView.deleteSections(indexRange, withRowAnimation: .Fade)
            UIApplication.sharedApplication().cancelAllLocalNotifications()
        }
        
        self.tableView.endUpdates()
    }
    
    func addReminder(section: RemindersAddSectionViewController, sectionIndex: Int) {
        // TODO: Schedule reminder for added reminder
        
        let reminderSection = ReminderSection(managedObjectContext: self.managedObjectContext, reminder: nil)
        sections.insert(reminderSection, atIndex: sectionIndex)
        
        var indexPaths : [NSIndexPath] = []
        for i in 1...(reminderSection.numberOfRows()) {
            indexPaths += [NSIndexPath(forRow: i, inSection: sectionIndex)]
        }

        self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
    }
    
    func loadRemindersSections() {
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = Reminder.entity(managedObjectContext)
        
        var error: NSError?
        reminders = managedObjectContext.executeFetchRequest(fetchRequest, error: &error)! as [Reminder]
        if error != nil {
            println("Fetch error: \(error)")
        }
        
        var i = 1
        for r in reminders {
            sections.insert(ReminderSection(managedObjectContext: managedObjectContext, reminder: r), atIndex: i)
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
        var cell: UITableViewCell!

        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("RemindersSwitchCell") as UITableViewCell
        } else if indexPath.section == sections.count - 1 {
            cell = tableView.dequeueReusableCellWithIdentifier("RemindersAddCell") as UITableViewCell
        } else {
            var nibName: String?
            if indexPath.row == 0 {
                nibName = "SettingsTableViewTimeCell"
            } else {
                nibName = "SettingsTableViewFrequencyCell"
            }
            let nibArray = NSBundle.mainBundle().loadNibNamed(nibName, owner: self, options: nil)
            cell = (nibArray[0] as UITableViewCell)
        }
        
        section.configureCell(cell!, atIndex: indexPath.row)
        return cell!
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return sections[indexPath.section].isEditable
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            self.tableView.beginUpdates()
            let reminderSection = sections[indexPath.section] as ReminderSection
            reminderSection.deleteReminder()
            sections.removeAtIndex(indexPath.section)
            rebuildNotifications()
            tableView.deleteSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Fade)
            self.tableView.endUpdates()
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        sections[indexPath.section].selectRow(atIndex: indexPath.row, inSection: indexPath.section, inTableView: tableView)
    }
    
    // MARK: UILocalNotification management
    
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
                let reminderSection = section as ReminderSection
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
