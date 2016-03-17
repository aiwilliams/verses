//
//  AddReminderController.swift
//  Verses
//
//  Created by Isaac Williams on 3/17/16.
//  Copyright © 2016 The Williams Family. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class AddReminderController: UIViewController {
    @IBOutlet var reminderTimePicker: UIDatePicker!

    @IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(sender: UIBarButtonItem) {
        saveReminder()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveReminder() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let entityDescription = NSEntityDescription.entityForName("Reminder", inManagedObjectContext: appDelegate.managedObjectContext)!
        let managedObject = NSManagedObject(entity: entityDescription, insertIntoManagedObjectContext: appDelegate.managedObjectContext)
        managedObject.setValue(reminderTimePicker.date, forKey: "time")
        
        do {
            try appDelegate.managedObjectContext.save()
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
}