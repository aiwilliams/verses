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
    @IBOutlet var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.hidden = true
    }

    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func doneButtonPressed(sender: AnyObject) {
        let cleanURL = cleanRawPassage(verseRequest.text!)
        if cleanURL == "failure" {
            errorLabel.hidden = false
        } else {
            let url = parsePassageIntoURLString(cleanURL)
            
            if url == "failure" {
                errorLabel.hidden = false
            } else {
                fetchAndSaveVerseText(url)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    func cleanRawPassage(rawPassage: String) -> String {
        if let spacesRegex: NSRegularExpression = try? NSRegularExpression(pattern: " ", options: NSRegularExpressionOptions.CaseInsensitive) {
            return spacesRegex.stringByReplacingMatchesInString(rawPassage, options: NSMatchingOptions.ReportCompletion, range: NSMakeRange(0, rawPassage.characters.count), withTemplate: "")
        }
        return "failure"
    }
    
    func parsePassageIntoURLString(rawPassage: String) -> String {
        let parseURL = NSURL(string: self.APIURL + "/parse/" + rawPassage)
        let parseData: NSData? = NSData(contentsOfURL: parseURL!)
        var parseJSON: AnyObject? = nil
        
        if parseData == nil { return "failure" } // they put in an out-of-bounds passage or something dumb
        
        do {
            parseJSON = try NSJSONSerialization.JSONObjectWithData(parseData!, options: NSJSONReadingOptions.AllowFragments)
        } catch _ as NSError {
            print("could not serialize parsed passage JSON from HeartVersesAPI")
        }
        
        if let data = parseJSON as? NSDictionary {
            if let book = data["book"] as? String {
                if let chapter = data["chapter"] as? Int {
                    if let verse = data["verse"] as? Int {
                        return "/kjv/\(book)/\(chapter)/\(verse)"
                    }
                }
            }
        }
        
        return "failure"
    }
    
    func fetchAndSaveVerseText(passageURL: String) {
        let verseURL = NSURL(string: self.APIURL + passageURL)!
        let verseData: NSData? = NSData(contentsOfURL: verseURL)
        var verseJSON: AnyObject? = nil
        
        do {
            verseJSON = try NSJSONSerialization.JSONObjectWithData(verseData!, options: NSJSONReadingOptions.AllowFragments)
        } catch _ as NSError {
            print("could not serialize verse text JSON from HeartVersesAPI")
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