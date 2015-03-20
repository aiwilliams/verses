//
//  ReminderDetailViewController.swift
//  verses
//
//  Created by Isaac Williams on 2/28/15.
//  Copyright (c) 2015 The Williams Family. All rights reserved.
//

import UIKit

class ReminderDetailViewController: UITableViewController {
    
    var reminder: Reminder!
    var delegate: ReminderEditorDelegate!
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let reminderSegueIDs = ["FrequencySegue", "TimeSegue"]
        
        if !contains(reminderSegueIDs, segue.identifier ?? "") { return }
        
        let reminderForm = segue.destinationViewController as ReminderForm
        reminderForm.reminder = self.reminder
        reminderForm.delegate = delegate
    }


}
