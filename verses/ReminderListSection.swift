//
//  ReminderListSection.swift
//  verses
//
//  Created by Isaac Williams on 3/6/15.
//  Copyright (c) 2015 The Williams Family. All rights reserved.
//

import UIKit
import CoreData

class RemindersListSection: SettingsSection {
    var managedObjectContext: NSManagedObjectContext
    lazy var reminders: [Reminder] = {
        let fetchRequest = NSFetchRequest()
        let entity: NSEntityDescription = NSEntityDescription.entityForName("Reminder", inManagedObjectContext: self.managedObjectContext)!
        fetchRequest.entity = entity
        
        var error: NSError?
        let fetchData = self.managedObjectContext.executeFetchRequest(fetchRequest, error: &error)!
        
        var reply: Reminder!
        if fetchData.count == 0 {
            reply = Reminder(entity: entity, insertIntoManagedObjectContext: self.managedObjectContext)
            reply.frequency = .DayCalendarUnit
            reply.time = NSDate()
            self.managedObjectContext.save(nil)
        } else {
            reply = fetchData[0] as Reminder
        }
        
        return [ reply ]
    }()
    
    var frequencies = [
        NSCalendarUnit.DayCalendarUnit.rawValue: "Daily",
        NSCalendarUnit.WeekCalendarUnit.rawValue: "Weekly",
        NSCalendarUnit.MonthCalendarUnit.rawValue: "Monthly"
    ]
    
    lazy var dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        return formatter
    }()
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }
    
    func enabledWhenRemindersOff() -> Bool {
        return false
    }
    
    func reuseIdentifier() -> String {
        return "ReminderCell"
    }
    
    func numberOfRows() -> Int {
        return reminders.count
    }
    
    func configureCell(cell: UITableViewCell, atIndex index: Int) {
        let reminder = reminders[index]
        cell.textLabel!.text = dateFormatter.stringFromDate(reminder.time)
        cell.detailTextLabel!.text = frequencies[UInt(reminder.rawFrequency)]
    }
}
