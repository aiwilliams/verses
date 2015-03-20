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
    var delegate: ReminderEditorDelegate!
    
    let defaultSettings = NSUserDefaults(suiteName: "settings")!
    
    override func viewDidLoad() {
        remindersDatePicker.setDate(self.reminder.time, animated: false)
    }
    
    @IBAction func dateDidChange(sender: AnyObject) {
        reminder.time = sender.date!!
        self.delegate!.reminderChanged(reminder)
    }
}