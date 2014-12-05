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

class SettingsTableViewController : UITableViewController {
    
    @IBOutlet var remindersSwitch: UISwitch!
    
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
    
}
