//
//  FrequencySettingsViewController.swift
//  verses
//
//  Created by Isaac Williams on 11/6/14.
//  Copyright (c) 2014 The Williams Family. All rights reserved.
//

import Foundation
import UIKit

class FrequencySettingsViewController : UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet var frequencyPicker: UIPickerView!
    
    var frequencyPickerDataSource = ["Daily", "Weekly", "Monthly"]
    let defaultSettings = NSUserDefaults(suiteName: "settings")
    
    override func viewDidLoad() {
        self.frequencyPicker.dataSource = self
        self.frequencyPicker.delegate = self
        
        if defaultSettings?.valueForKey("remindersFrequency") != nil {
            if defaultSettings?.valueForKey("remindersFrequency") as String == "Daily" {
                frequencyPicker.selectRow(0, inComponent: 0, animated: false)
            }
            else if defaultSettings?.valueForKey("remindersFrequency") as String == "Weekly" {
                frequencyPicker.selectRow(1, inComponent: 0, animated: false)
            }
            else if defaultSettings?.valueForKey("remindersFrequency") as String == "Monthly" {
                frequencyPicker.selectRow(2, inComponent: 0, animated: false)
            }
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return frequencyPickerDataSource.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return frequencyPickerDataSource[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        defaultSettings?.setValue(frequencyPickerDataSource[row], forKey: "remindersFrequency")
    }
}