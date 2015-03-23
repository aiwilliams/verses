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
    
    // Answer the unique identifier of this Reminder. It will be correct only after the object has been saved.
    var uri: String! {
        return objectID.URIRepresentation().absoluteString
    }
    
    var nextFireDate: NSDate! {
        if fireDate.timeIntervalSinceNow > 0.0 {
            return fireDate
        }
        
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
        
        return NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: fireDate, options: nil)!
    }
    
    var repeatInterval: NSCalendarUnit {
        get { return NSCalendarUnit(UInt(self.rawRepeatInterval)) }
        set(newInterval) { self.rawRepeatInterval = newInterval.rawValue }
    }
}
