//
//  RemindersSwitchSection.swift
//  verses
//
//  Created by Isaac Williams on 3/6/15.
//  Copyright (c) 2015 The Williams Family. All rights reserved.
//

import UIKit

protocol RemindersSwitchSectionDelegate {
    func remindersSwitchSet(#on: Bool)
}

class RemindersSwitchSection: NSObject, SettingsSection { // ...don't ask
    var delegate: RemindersSwitchSectionDelegate
    var remindersSwitch: UISwitch
    
    init(delegate: RemindersSwitchSectionDelegate, switchOn: Bool) {
        self.delegate = delegate
        remindersSwitch = UISwitch() // "switch" is an operator for bad programmers
        super.init()
        
        self.remindersSwitch.on = switchOn
        self.remindersSwitch.addTarget(self, action: "switchChanged", forControlEvents: .ValueChanged)
    } 
    
    func switchChanged() {
        self.delegate.remindersSwitchSet(on: self.remindersSwitch.on)
    }
    
    func enabledWhenRemindersOff() -> Bool {
        return true
    }
    
    func reuseIdentifier() -> String {
        return "RemindersSwitchCell"
    }
    
    func numberOfRows() -> Int {
        return 1
    }
    
    func configureCell(cell: UITableViewCell, atIndex index: Int) {
        cell.accessoryView = self.remindersSwitch
        cell.selectionStyle = .None
    }
}
