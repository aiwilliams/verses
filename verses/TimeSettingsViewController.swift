//
//  TimeSettingsViewController.swift
//  verses
//
//  Created by Isaac Williams on 11/6/14.
//  Copyright (c) 2014 The Williams Family. All rights reserved.
//

import Foundation
import UIKit

class TimeSettingsViewController : UIViewController, ReminderForm {
    
    @IBOutlet var remindersDatePicker: UIDatePicker!
    
    var reminder: Reminder!
    let defaultSettings = NSUserDefaults(suiteName: "settings")!
    
    override func viewDidLoad() {
        remindersDatePicker.setDate(self.reminder.time, animated: false)
    }
    
    @IBAction func dateDidChange(sender: AnyObject) {
        reminder.time = sender.date!!
        reminder.managedObjectContext!.save(nil)
        
        if defaultSettings.valueForKey("remindersSwitch") as NSString == "off" { return }
        
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        let localNotification: UILocalNotification = UILocalNotification()
        localNotification.timeZone = NSTimeZone.defaultTimeZone()
        
        let calendar = NSCalendar.currentCalendar()
        let components: NSDateComponents = calendar.components(NSCalendarUnit.HourCalendarUnit | NSCalendarUnit.MinuteCalendarUnit, fromDate: reminder.time)
        
        localNotification.fireDate = NSCalendar.currentCalendar().dateFromComponents(components)
        localNotification.repeatInterval = reminder.frequency
        
        let appDelegate = UIApplication.sharedApplication().delegate! as AppDelegate
        if let biblePassage = appDelegate.biblePassageStore.activeBiblePassage() {
            localNotification.alertBody = "\(biblePassage.passage)"
        }
        else {
            localNotification.alertBody = "You don't have any verses!"
        }
        
        localNotification.hasAction = true
        localNotification.applicationIconBadgeNumber = localNotification.applicationIconBadgeNumber + 1
        
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
    
    func formattedDate(passedDate: NSDate) -> NSString {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let postDate = dateFormatter.stringFromDate(passedDate)
        
        return postDate
    }
}