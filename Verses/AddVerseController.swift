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
    var APIURL: String = "http://heartversesapi.herokuapp.com/api/v1"
    @IBOutlet var verseRequest: UITextField!

    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func doneButtonPressed(sender: AnyObject) {
        fetchVerseTextFromAPI(verseRequest.text!)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func fetchVerseTextFromAPI(passage: String) {
        let verseURL = NSURL(string: self.APIURL + verseRequest.text!)!
        let verseData: NSData? = NSData(contentsOfURL: verseURL)
        var verseJSON: AnyObject? = nil

        do {
            verseJSON = try NSJSONSerialization.JSONObjectWithData(verseData!, options: NSJSONReadingOptions.AllowFragments)
        } catch _ as NSError {
            print("could not serialize JSON from HeartVersesAPI")
        }
        
        if let data = verseJSON as? NSDictionary {
            if let verses = data["verses"] as? NSArray {
                if let topVerse = verses[0] as? NSDictionary {
                    if let text = topVerse["text"] as? String {
                        if let book = topVerse["book"] as? String {
                            if let chapter = topVerse["chapter"] as? Int {
                                if let verse = topVerse["verse"] as? Int {
                                    let passage = "\(book) \(chapter):\(verse)"
                                    saveVerse(passage, text: text)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func saveVerse(passage: String, text: String) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let moc = appDelegate.managedObjectContext
        let entity = NSEntityDescription.entityForName("Verse", inManagedObjectContext: moc)
        let verse = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: moc)
        verse.setValue(passage, forKey: "passage")
        verse.setValue(text, forKey: "text")
        
        do {
            try moc.save()
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
}