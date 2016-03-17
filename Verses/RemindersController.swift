//
//  RemindersController.swift
//  Verses
//
//  Created by Isaac Williams on 3/14/16.
//  Copyright © 2016 The Williams Family. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class RemindersController: UITableViewController {
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var reminders: [NSManagedObject]!

    override func viewWillAppear(animated: Bool) {
        let moc = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Reminder")
        
        do {
            let results = try moc.executeFetchRequest(fetchRequest)
            reminders = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        tableView.reloadData()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminders.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reminder = reminders[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("reminderCell") as! ReminderCell

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        cell.timeLabel.text = dateFormatter.stringFromDate(reminder.valueForKey("time") as! NSDate)

        let toggleSwitch = UISwitch()
        toggleSwitch.on = reminder.valueForKey("on") as! Bool
        toggleSwitch.addTarget(self, action: Selector("reminderSwitchChanged:"), forControlEvents: .ValueChanged)
        toggleSwitch.tag = indexPath.row
        cell.accessoryView = toggleSwitch

        return cell
    }
    
    func reminderSwitchChanged(sender: UISwitch) {
        let reminder = reminders[sender.tag]
        reminder.setValue(sender.on, forKey: "on")
        try! appDelegate.managedObjectContext.save()
        
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        for r in reminders {
            if r.valueForKey("on") as! Bool {
                scheduleReminder(r)
            }
        }
    }
    
    func scheduleReminder(reminder: NSManagedObject) {
        guard let settings = UIApplication.sharedApplication().currentUserNotificationSettings() else { return }
        
        if settings.types == .None {
            let ac = UIAlertController(title: "Can't schedule", message: "We don't have permission to schedule notifications! Please allow it in your Settings.", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
            return
        }
        
        let notif = UILocalNotification()
        notif.fireDate = reminder.valueForKey("time") as? NSDate
        notif.alertBody = "It's time to memorize!"
        notif.soundName = UILocalNotificationDefaultSoundName
        notif.repeatInterval = .Day
        UIApplication.sharedApplication().scheduleLocalNotification(notif)
    }
}