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
    
    let passageParser = PassageParser()
    let API = HeartversesAPI(defaultTranslation: "kjv")
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.hidden = true
    }

    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func doneButtonPressed(sender: AnyObject) {
        let parsedPassage = passageParser.parse(verseRequest.text!)
        let passage = API.fetchPassage(parsedPassage)
        savePassage(passage)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func savePassage(passage: Passage) {
        let entity = NSEntityDescription.entityForName("Passage", inManagedObjectContext: appDelegate.managedObjectContext)
        let CDPassage = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: appDelegate.managedObjectContext)
        let verseSet = NSMutableOrderedSet()
        for v in passage.verses {
            let verse = convertVerseToNSManagedObject(v)
            verseSet.addObject(verse)
        }
        CDPassage.setValue(verseSet, forKey: "verses")
        
        do {
            try appDelegate.managedObjectContext.save()
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func convertVerseToNSManagedObject(verse: Verse) -> NSManagedObject {
        let entity = NSEntityDescription.entityForName("Verse", inManagedObjectContext: appDelegate.managedObjectContext)
        let nsmo = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: appDelegate.managedObjectContext)
        nsmo.setValue(verse.book, forKey: "book")
        nsmo.setValue(verse.chapter, forKey: "chapter")
        nsmo.setValue(verse.number, forKey: "number")
        nsmo.setValue(verse.text, forKey: "text")

        return nsmo
    }
}