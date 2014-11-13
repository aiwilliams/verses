//
//  TimeSettingsViewController.swift
//  verses
//
//  Created by Isaac Williams on 11/6/14.
//  Copyright (c) 2014 The Williams Family. All rights reserved.
//

import Foundation
import UIKit

class TimeSettingsViewController : UIViewController {
    
    @IBOutlet var remindersDatePicker: UIDatePicker!
    
    let defaultSettings = NSUserDefaults(suiteName: "settings")!
    
    override func viewDidLoad() {
        if defaultSettings.valueForKey("remindersTime") != nil {
            let stringTime: String = defaultSettings.valueForKey("remindersTime") as String
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            let time = dateFormatter.dateFromString(stringTime)
            remindersDatePicker.setDate(time!, animated: false)
        }
    }
    
    @IBAction func dateDidChange(sender: AnyObject) {
        let remindersTime = formattedDate(sender.date!!)
        defaultSettings.setValue(remindersTime, forKey: "remindersTime")
        
        if defaultSettings.valueForKey("remindersSwitch") as NSString == "on" {
            println("Rescheduling UILocalNotification based on a change in time settings...")
            
            UIApplication.sharedApplication().cancelAllLocalNotifications()
            
            let localNotification: UILocalNotification = UILocalNotification()
            
            localNotification.timeZone = NSTimeZone.defaultTimeZone()
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            let userTimeSettings: String = defaultSettings.valueForKey("remindersTime") as String
            let dateTime = dateFormatter.dateFromString(userTimeSettings)
            let components = NSCalendar.currentCalendar().components(NSCalendarUnit.HourCalendarUnit, fromDate: dateTime!)
            
            // localNotification.timeZone = NSTimeZone(name: "GMT")
            localNotification.fireDate = NSCalendar.currentCalendar().dateFromComponents(components)
            
            if defaultSettings.valueForKey("remindersFrequency") as String == "Daily" {
                localNotification.repeatInterval = NSCalendarUnit.CalendarUnitDay
            }
            else if defaultSettings.valueForKey("remindersFrequency") as String == "Weekly" {
                localNotification.repeatInterval = NSCalendarUnit.CalendarUnitWeekday
            }
            else {
                localNotification.repeatInterval = NSCalendarUnit.CalendarUnitMonth
            }
            
            let appDelegate = UIApplication.sharedApplication().delegate! as AppDelegate
            let biblePassage = appDelegate.biblePassageStore.activeBiblePassage()
            
            localNotification.alertBody = "\(biblePassage?.passage)"
            localNotification.hasAction = true
            localNotification.applicationIconBadgeNumber = localNotification.applicationIconBadgeNumber + 1
            
            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        }
    }
    
    func formattedDate(passedDate: NSDate) -> NSString {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let postDate = dateFormatter.stringFromDate(passedDate)
        
        return postDate
    }
}