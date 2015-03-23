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
        
        var userInfo = [String:String]()
        userInfo["reminderURI"] = reminder.uri
        
        self.userInfo = userInfo
        
        self.hasAction = true
        self.applicationIconBadgeNumber = 1
        self.timeZone = NSTimeZone.defaultTimeZone()
        self.fireDate = reminder.fireDate
        self.repeatInterval = reminder.repeatInterval

        self.alertBody = alertBody
    }
 
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}