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
    
    var lastVerseRef: AnyObject?
    var lastVerseContent: AnyObject?
    
    override func viewDidLoad() {

        // Get the NSUserDefaults ready...
        
        let settingsDefaults = NSUserDefaults(suiteName: "settings")
        
        // Fetch verses from CoreData...
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let moc = appDelegate.userManagedObjectContext

        let entityDescription: NSEntityDescription = NSEntityDescription.entityForName("BiblePassage", inManagedObjectContext: moc)!
        let request: NSFetchRequest = NSFetchRequest()
        request.entity = entityDescription
        request.resultType = NSFetchRequestResultType.DictionaryResultType
        
        let objects: NSArray = moc.executeFetchRequest(request, error: nil)!
        
        let lastCoreDataObject: AnyObject? = objects.lastObject
        lastVerseRef = lastCoreDataObject!.valueForKey("passage")
        lastVerseContent = lastCoreDataObject!.valueForKey("content")
        
        // Check for previous user settings...
        
        if settingsDefaults?.valueForKey("remindersSwitch") != nil {
            if settingsDefaults?.valueForKey("remindersSwitch") as String == "on" {
                remindersSwitch.setOn(true, animated: false)
            }
            else {
                remindersSwitch.setOn(false, animated: false)
            }
        }
        
    }

    @IBAction func didToggleReminders(sender: UISwitch) {
        let defaults = NSUserDefaults(suiteName: "settings")
        
        if sender.on == true {
            defaults!.setValue("on", forKey: "remindersSwitch")
            
            let localNotification: UILocalNotification = UILocalNotification()
            
            localNotification.timeZone = NSTimeZone.defaultTimeZone()
            
            let comps: NSDateComponents = NSDateComponents()
            comps.hour = 7
            
            localNotification.fireDate = NSCalendar.currentCalendar().dateFromComponents(comps)
            if defaults?.valueForKey("remindersFrequency") as String == "Daily" {
                localNotification.repeatInterval = NSCalendarUnit.CalendarUnitDay
            }
            else if defaults?.valueForKey("remindersFrequency") as String == "Weekly" {
                localNotification.repeatInterval = NSCalendarUnit.CalendarUnitWeekday
            }
            else {
                localNotification.repeatInterval = NSCalendarUnit.CalendarUnitMonth
            }
            localNotification.alertBody = "\(lastVerseRef)"
            localNotification.hasAction = true
            localNotification.applicationIconBadgeNumber = localNotification.applicationIconBadgeNumber + 1
            
            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        }
        else {
            defaults!.setValue("off", forKey: "remindersSwitch")
        }
    }
    
}