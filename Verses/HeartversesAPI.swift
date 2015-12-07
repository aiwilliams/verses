//
//  HeartversesAPI.swift
//  Verses
//
//  Created by Isaac Williams on 12/7/15.
//  Copyright © 2015 The Williams Family. All rights reserved.
//

import Foundation
import CoreData

var APIURL: String = "http://heartversesapi.herokuapp.com/api/v1"

class HeartversesAPI {
    static func fetchVerseText(rawPassage: String) -> String {
        let parsedPassage = parsePassage(rawPassage)
        let passageURL = URLStringFromPassage(parsedPassage)
        let verseURL = NSURL(string: APIURL + passageURL)!
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
                        return text
                    }
                }
            }
        }
        
        return "failure"
    }
    
    static func parsePassage(passage: String) -> String {
        let parseURL = NSURL(string: APIURL + "/parse/" + removeSpacesFromRawPassage(passage))
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
                        return "\(book) \(chapter):\(verse)"
                    }
                }
            }
        }
        
        return "failure"
    }
    
    static private func URLStringFromPassage(passage: String) -> String {
        let comps = passage.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: " :"))
        return "/kjv/\(comps[0])/\(comps[1])/\(comps[2])"
    }
    
    static private func removeSpacesFromRawPassage(rawPassage: String) -> String {
        if let spacesRegex: NSRegularExpression = try? NSRegularExpression(pattern: " ", options: NSRegularExpressionOptions.CaseInsensitive) {
            return spacesRegex.stringByReplacingMatchesInString(rawPassage, options: NSMatchingOptions.ReportCompletion, range: NSMakeRange(0, rawPassage.characters.count), withTemplate: "")
        }
        return "failure"
    }
}