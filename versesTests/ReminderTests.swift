//
//  ReminderTests.swift
//  verses
//
//  Created by Christian Di Lorenzo on 4/3/15.
//  Copyright (c) 2015 The Williams Family. All rights reserved.
//

import XCTest
import CoreData

class ReminderTests : XCTestCase {
    var managedObjectContext : NSManagedObjectContext?
    
    override func setUp() {
        let managedObjectModel = NSManagedObjectModel.mergedModelFromBundles([NSBundle.mainBundle()])!
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        persistentStoreCoordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil, error: nil)
        managedObjectContext = NSManagedObjectContext()
        managedObjectContext!.persistentStoreCoordinator = persistentStoreCoordinator
    }
    
    func testIntervalDescription() {
        let reminder = Reminder(managedObjectContext)
        reminder.repeatInterval = .CalendarUnitWeekday
        XCTAssertEqual(reminder.repeatIntervalDescription(), "Weekly")
    }
}