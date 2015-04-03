//
//  Reminder.swift
//  verses
//
//  Created by Isaac Williams on 1/23/15.
//  Copyright (c) 2015 The Williams Family. All rights reserved.
//

import CoreData
import UIKit

class Reminder: NSManagedObject {

    @NSManaged var rawRepeatInterval: NSNumber
    @NSManaged var fireDate: NSDate
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        self.fireDate = NSDate()
        self.repeatInterval = .CalendarUnitDay
    }
    
    convenience init(_ context: NSManagedObjectContext!) {
        self.init(entity: Reminder.entity(context), insertIntoManagedObjectContext: context)
    }
    
    class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription {
        return NSEntityDescription.entityForName("Reminder", inManagedObjectContext: managedObjectContext)!
    }
    
    // Answer the unique identifier of this Reminder. It will be correct only after the object has been saved.
    var uri: String! {
        return objectID.URIRepresentation().absoluteString
    }
    
    var nextFireDate: NSDate {
        if fireDate.timeIntervalSinceNow > 0.0 {
            return fireDate
        }

        let calendar = NSCalendar.currentCalendar()
        let estimatedComponents = calendar.components(repeatInterval, fromDate: fireDate, toDate: NSDate(), options: nil)
        let estimatedDate = calendar.dateByAddingComponents(estimatedComponents, toDate: fireDate, options: nil)!
        
        var nextDate = estimatedDate
        if estimatedDate.timeIntervalSinceNow < 0 { // date is slightly after current date
            nextDate = calendar.dateByAddingComponents(repeatIntervalComponents(), toDate: estimatedDate, options: nil)!
        }
        
        return nextDate
    }
    
    var repeatInterval: NSCalendarUnit {
        get { return NSCalendarUnit(UInt(self.rawRepeatInterval)) }
        set(newInterval) { self.rawRepeatInterval = newInterval.rawValue }
    }
    
    func repeatIntervalDescription() -> String {
        switch repeatInterval {
        case NSCalendarUnit.CalendarUnitDay:
            return "Daily"
        case NSCalendarUnit.CalendarUnitWeekday:
            return "Weekly"
        case NSCalendarUnit.CalendarUnitMonth:
            return "Monthly"
        default:
            return "Unknown"
        }
    }
    
    func repeatIntervalComponents() -> NSDateComponents {
        let components = NSDateComponents()
        switch repeatInterval {
        case NSCalendarUnit.CalendarUnitDay:
            components.day = 1;
        case NSCalendarUnit.CalendarUnitWeekday:
            components.day = 7;
        case NSCalendarUnit.CalendarUnitMonth:
            components.month = 1;
        default:
            break;
        }
        
        return components
    }
}
