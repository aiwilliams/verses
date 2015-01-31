//
//  FrequencySettingsViewController.swift
//  verses
//
//  Created by Isaac Williams on 11/6/14.
//  Copyright (c) 2014 The Williams Family. All rights reserved.
//

import Foundation
import UIKit

class FrequencySettingsViewController : UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, ReminderForm {
    
    @IBOutlet var frequencyPicker: UIPickerView!
    
    var reminder: Reminder!
    var frequencyPickerDataSource: [NSCalendarUnit] = [.DayCalendarUnit, .WeekCalendarUnit, .MonthCalendarUnit]
    var frequencyPickerTitles = ["Day", "Week", "Month"]
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    let defaultSettings = NSUserDefaults(suiteName: "settings")!
    
    override func viewDidLoad() {
        self.frequencyPicker.dataSource = self
        self.frequencyPicker.delegate = self
        self.frequencyPicker.selectRow(find(self.frequencyPickerDataSource, self.reminder.frequency)!, inComponent: 0, animated: false)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return frequencyPickerDataSource.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return frequencyPickerTitles[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.reminder.frequency = frequencyPickerDataSource[row]
        let managedObjectContext = self.appDelegate.managedObjectContext
        managedObjectContext.save(nil)
        
        if defaultSettings.valueForKey("remindersSwitch") as NSString == "off" { return }
        
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        let localNotification: UILocalNotification = UILocalNotification()
        localNotification.timeZone = NSTimeZone.defaultTimeZone()
        let components = NSCalendar.currentCalendar().components(NSCalendarUnit.HourCalendarUnit, fromDate: reminder.time)
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
}