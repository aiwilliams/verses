//
//  SettingsTableViewFrequencyCell.swift
//  verses
//
//  Created by Isaac Williams on 4/4/15.
//  Copyright (c) 2015 The Williams Family. All rights reserved.
//

import Foundation
import UIKit

class SettingsTableViewFrequencyCell: UITableViewCell, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet var picker: UIPickerView!
    
    var reminder: Reminder!
    
    var frequencyPickerDataSource: [NSCalendarUnit] = [.CalendarUnitDay, .CalendarUnitWeekday, .CalendarUnitMonth]
    var frequencyPickerTitles = ["Day", "Week", "Month"]
    
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    func customInitialization() {
        self.picker.dataSource = self
        self.picker.delegate = self
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
//        self.reminder.repeatInterval = frequencyPickerDataSource[row]

    }
}