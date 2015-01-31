//
//  SettingsTableViewController.swift
//  verses
//
//  Created by Isaac Williams on 11/4/14.
//  Copyright (c) 2014 The Williams Family. All rights reserved.
//

import Foundation
import UIKit
import CoreData

@objc protocol ReminderForm {
    var reminder: Reminder! { get set }
}

class SettingsTableViewController : UITableViewController {
    
    var data = []
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    lazy var managedObjectContext: NSManagedObjectContext = { self.appDelegate.managedObjectContext }()
    @IBOutlet var remindersSwitch: UISwitch!
    
    lazy var reminder: Reminder = {
        let fetchRequest = NSFetchRequest()
        let entity: NSEntityDescription = NSEntityDescription.entityForName("Reminder", inManagedObjectContext: self.managedObjectContext)!
        fetchRequest.entity = entity
        
        var error: NSError?
        let fetchData = self.appDelegate.managedObjectContext.executeFetchRequest(fetchRequest, error: &error)!
        
        var reply: Reminder!
        if fetchData.count == 0 {
            reply = Reminder(entity: entity, insertIntoManagedObjectContext: self.managedObjectContext)
            reply.frequency = .DayCalendarUnit
            reply.time = NSDate()
            self.managedObjectContext.save(nil)
        } else {
            reply = fetchData[0] as Reminder
        }
        
        return reply
        }()
    
    override func viewDidLoad() {
        remindersSwitch.setOn(false, animated: false)
        let defaults = NSUserDefaults(suiteName: "settings")!
        if let state = defaults.valueForKey("remindersSwitch") as? String {
            remindersSwitch.setOn(state == "on", animated: false)
        }
        
        if defaults.valueForKey("remindersSwitch") == nil {
            defaults.setValue("off", forKey: "remindersSwitch")
        }
        
        if defaults.valueForKey("remindersFrequency") == nil {
            defaults.setValue("Daily", forKey: "remindersFrequency")
        }
        
        if defaults.valueForKey("remindersTime") == nil {
            defaults.setValue("9:00", forKey: "remindersTime")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let reminderSegueIDs = ["FrequencySegue", "TimeSegue"]
        if !contains(reminderSegueIDs, segue.identifier ?? "") { return }
        
        let reminderForm = segue.destinationViewController as ReminderForm
        reminderForm.reminder = self.reminder
    }
    
    @IBAction func didToggleReminders(sender: UISwitch) {
        let defaults = NSUserDefaults(suiteName: "settings")!
        
        if sender.on == true {
            defaults.setValue("on", forKey: "remindersSwitch")
            
            UIApplication.sharedApplication().cancelAllLocalNotifications()
            
            let localNotification: UILocalNotification = UILocalNotification()
            
            localNotification.timeZone = NSTimeZone.defaultTimeZone()
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            let userTimeSettings: String = defaults.valueForKey("remindersTime") as String
            let dateTime = dateFormatter.dateFromString(userTimeSettings)
            let components = NSCalendar.currentCalendar().components(NSCalendarUnit.HourCalendarUnit, fromDate: dateTime!)
            
            localNotification.fireDate = NSCalendar.currentCalendar().dateFromComponents(components)
            
            if defaults.valueForKey("remindersFrequency") as String == "Daily" {
                localNotification.repeatInterval = NSCalendarUnit.CalendarUnitDay
            }
            else if defaults.valueForKey("remindersFrequency") as String == "Weekly" {
                localNotification.repeatInterval = NSCalendarUnit.CalendarUnitWeekday
            }
            else {
                localNotification.repeatInterval = NSCalendarUnit.CalendarUnitMonth
            }
            
            let appDelegate = UIApplication.sharedApplication().delegate! as AppDelegate
            if let biblePassage = appDelegate.biblePassageStore.activeBiblePassage() {
                localNotification.alertBody = "\(biblePassage.passage)"
            }
            else {
                localNotification.alertBody = "Unknown Verse"
            }
            localNotification.hasAction = true
            localNotification.applicationIconBadgeNumber = localNotification.applicationIconBadgeNumber + 1
            
            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        } else {
            defaults.setValue("off", forKey: "remindersSwitch")
            UIApplication.sharedApplication().cancelAllLocalNotifications()
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        <#code#>
//    }
    
    @IBAction func didAddReminder(sender: AnyObject) {

    }
}
