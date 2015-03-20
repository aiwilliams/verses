//
//  ReminderNotification.swift
//  verses
//
//  Created by Isaac Williams on 3/20/15.
//  Copyright (c) 2015 The Williams Family. All rights reserved.
//

import UIKit

class ReminderNotification: UILocalNotification {
    init(reminder: Reminder, alertBody: String) {
        super.init()
        
        self.hasAction = true
        self.applicationIconBadgeNumber = 1
        self.timeZone = NSTimeZone.defaultTimeZone()
        
        self.repeatInterval = reminder.frequency
        self.alertBody = alertBody
        
        let components = NSCalendar.currentCalendar().components(.DayCalendarUnit, fromDate: reminder.time)
        self.fireDate = NSCalendar.currentCalendar().dateFromComponents(components)
    }
 
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}