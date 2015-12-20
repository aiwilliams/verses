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
    @IBOutlet var passagePreviewLabel: UILabel!
    
    let passageParser = PassageParser()
    let API = HeartversesAPI(defaultTranslation: "kjv")
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.hidden = true
        passagePreviewLabel.hidden = true
        verseRequest.becomeFirstResponder()
        verseRequest.addTarget(self, action: "textFieldDidChange:", forControlEvents: .EditingChanged)
    }
    
    func textFieldDidChange(notification: NSNotification) {
        do {
            let passage = try self.fetchPassage()
            passagePreviewLabel.text = passage.verses.first!.text
            passagePreviewLabel.hidden = false
        } catch {
        }
    }

    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func doneButtonPressed(sender: AnyObject) {
        do {
            let passage = try self.fetchPassage()
            savePassage(passage)
            self.dismissViewControllerAnimated(true, completion: nil)
        } catch HeartversesAPI.FetchError.PassageDoesNotExist {
            errorLabel.text = "That passage does not exist!"
            errorLabel.hidden = false
        } catch {
            errorLabel.text = "Sorry, an unknown error ocurred."
            errorLabel.hidden = false
        }
    }
    
    func fetchPassage() throws -> Passage {
        let parsedPassage = passageParser.parse(verseRequest.text!)
        do {
            let passage = try API.fetchPassage(parsedPassage)
            return passage
        } catch {
            passagePreviewLabel.text = ""
            throw HeartversesAPI.FetchError.PassageDoesNotExist
        }
    }
    
    func savePassage(passage: Passage) {
        let entityDescription = NSEntityDescription.entityForName("UserPassage", inManagedObjectContext: appDelegate.managedObjectContext)!
        let managedObject = UserPassage(entity: entityDescription, insertIntoManagedObjectContext: appDelegate.managedObjectContext)
        let verseSet = NSMutableOrderedSet()
        for v in passage.verses {
            let verse = convertVerseToNSManagedObject(v)
            verseSet.addObject(verse)
        }
        managedObject.verses = verseSet
        managedObject.reference = passage.reference
        
        do {
            try appDelegate.managedObjectContext.save()
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func convertVerseToNSManagedObject(verse: Verse) -> NSManagedObject {
        let entity = NSEntityDescription.entityForName("UserVerse", inManagedObjectContext: appDelegate.managedObjectContext)
        let nsmo = UserVerse(entity: entity!, insertIntoManagedObjectContext: appDelegate.managedObjectContext)
        nsmo.book = verse.book
        nsmo.chapter = verse.chapter
        nsmo.number = verse.number
        nsmo.text = verse.text
        nsmo.views = 0

        return nsmo
    }
}