//
//  AddVerseController.swift
//  Verses
//
//  Created by Isaac Williams on 11/12/15.
//  Copyright © 2015 The Williams Family. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class AddVerseController: UIViewController {
    @IBOutlet var verseRequest: UITextField!
    @IBOutlet var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.hidden = true
    }

    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func doneButtonPressed(sender: AnyObject) {
        saveVerse(HeartversesAPI.parsePassage(verseRequest.text!), text: HeartversesAPI.fetchVerseText(verseRequest.text!))
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveVerse(passage: String, text: String) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let moc = appDelegate.managedObjectContext
        let entity = NSEntityDescription.entityForName("Passage", inManagedObjectContext: moc)
        let verse = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: moc)
        verse.setValue(passage, forKey: "reference")
        verse.setValue(text, forKey: "text")
        
        do {
            try moc.save()
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
}