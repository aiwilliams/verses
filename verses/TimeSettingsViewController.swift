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
    
    let defaultSettings = NSUserDefaults(suiteName: "settings")
    
    override func viewDidLoad() {
        if defaultSettings?.valueForKey("remindersTime") != nil {
            let stringTime: String = defaultSettings?.valueForKey("remindersTime") as String
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            let time = dateFormatter.dateFromString(stringTime)
            remindersDatePicker.setDate(time!, animated: false)
        }
    }
    
    @IBAction func dateDidChange(sender: AnyObject) {
        let remindersTime = formattedDate(sender.date!!)
        defaultSettings?.setValue(remindersTime, forKey: "remindersTime")
    }
    
    func formattedDate(passedDate: NSDate) -> NSString {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let postDate = dateFormatter.stringFromDate(passedDate)
        
        return postDate
    }
}