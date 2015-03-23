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
    var delegate: ReminderFormDelegate!
    
    let defaultSettings = NSUserDefaults(suiteName: "settings")!
    
    override func viewDidLoad() {
        remindersDatePicker.setDate(self.reminder.fireDate, animated: false)
    }
    
    @IBAction func dateDidChange(sender: AnyObject) {
        let existingComponents = NSCalendar.currentCalendar().components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay, fromDate: self.reminder.fireDate)
        let pickerComponents = NSCalendar.currentCalendar().components(.CalendarUnitHour | .CalendarUnitMinute, fromDate: sender.date!!)

        existingComponents.hour = pickerComponents.hour
        existingComponents.minute = pickerComponents.minute
        
        reminder.fireDate = NSCalendar.currentCalendar().dateFromComponents(existingComponents)!

        self.delegate!.reminderChanged(reminder)
    }
}