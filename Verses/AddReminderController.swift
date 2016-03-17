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
        scheduleReminder()
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
    
    func scheduleReminder() {
        guard let settings = UIApplication.sharedApplication().currentUserNotificationSettings() else { return }

        if settings.types == .None {
            let ac = UIAlertController(title: "Can't schedule", message: "We don't have permission to schedule notifications! Please allow it in your Settings.", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
            return
        }

        let notif = UILocalNotification()
        notif.fireDate = reminderTimePicker.date
        notif.alertBody = "It's time to memorize!"
        notif.soundName = UILocalNotificationDefaultSoundName
        notif.repeatInterval = .Day
        UIApplication.sharedApplication().scheduleLocalNotification(notif)
    }
}