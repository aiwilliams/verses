//
//  Reminder.swift
//  verses
//
//  Created by Isaac Williams on 1/23/15.
//  Copyright (c) 2015 The Williams Family. All rights reserved.
//

import Foundation
import CoreData

class Reminder: NSManagedObject {

    @NSManaged var rawFrequency: NSNumber
    @NSManaged var time: NSDate
    
    var frequency: NSCalendarUnit {
        get { return NSCalendarUnit(UInt(self.rawFrequency)) }
        set(newFrequency) { self.rawFrequency = newFrequency.rawValue }
    }
}
