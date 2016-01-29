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
    @IBOutlet var translationLabel: UILabel!
    
    let passageParser = PassageParser()
    let API = HeartversesAPI()
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorLabel.alpha = 0
        passagePreviewLabel.alpha = 0
        
        verseRequest.becomeFirstResponder()
        verseRequest.addTarget(self, action: "updateVersePreview", forControlEvents: .EditingChanged)

        updateTranslationDisclosure()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("viewWillEnterForeground"), name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    func viewWillEnterForeground() {
        updateVersePreview()
        updateTranslationDisclosure()
    }

    func updateVersePreview() {
        do {
            let passage = try self.fetchPassage()
            passagePreviewLabel.text = passage.verses.first!.text
            UIView.animateWithDuration(0.3, animations: { self.passagePreviewLabel.alpha = 1 })
        } catch {
            UIView.animateWithDuration(0.3, animations: { self.passagePreviewLabel.alpha = 0 })
        }
    }
    
    func updateTranslationDisclosure() {
        let preferredTranslation = userDefaults.stringForKey("preferredBibleTranslation")!
        translationLabel.text = "Translation: \(preferredTranslation)"
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
            UIView.animateWithDuration(0.7, animations: { self.errorLabel.alpha = 1 })
            NSTimer.scheduledTimerWithTimeInterval(2.5, target: self, selector: Selector("hideErrorLabel"), userInfo: nil, repeats: false)
        } catch {
            errorLabel.text = "Sorry, an unknown error ocurred."
            UIView.animateWithDuration(0.7, animations: { self.errorLabel.alpha = 1 })
            NSTimer.scheduledTimerWithTimeInterval(2.5, target: self, selector: Selector("hideErrorLabel"), userInfo: nil, repeats: false)
        }
    }
    
    func hideErrorLabel() {
        UIView.animateWithDuration(0.7, animations: { self.errorLabel.alpha = 0 })
    }

    @IBAction func launchSettings(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
    }

    func fetchPassage() throws -> Passage {
        let parsedPassage = passageParser.parse(verseRequest.text!)
        do {
            let preferredTranslation = userDefaults.stringForKey("preferredBibleTranslation")!
            let passage = try API.fetchPassage(parsedPassage, translation: preferredTranslation.lowercaseString)
            return passage
        } catch HeartversesAPI.FetchError.PassageDoesNotExist {
            throw HeartversesAPI.FetchError.PassageDoesNotExist
        } catch HeartversesAPI.FetchError.InvalidRange {
            throw HeartversesAPI.FetchError.InvalidRange
        }
    }
    
    func savePassage(passage: Passage) {  // Maybe we should have a something that handles all Core Data interactions instead of always leaving it up to the controllers
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