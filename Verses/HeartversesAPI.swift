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
    enum FetchError: ErrorType {
        case PassageDoesNotExist
        case AmbiguousBookName
        case InvalidRange
    }
    
    func validatePassage(parsedPassage: ParsedPassage) -> (valid: Bool, error: ErrorType?) {
        if parsedPassage.book == "ambiguous" { return (false, FetchError.AmbiguousBookName) }
        if parsedPassage.verse_start > parsedPassage.verse_end { return (false, FetchError.InvalidRange) }
        if parsedPassage.chapter_start > parsedPassage.chapter_end { return (false, FetchError.InvalidRange) }
        if parsedPassage.chapter_start < 1 { return (false, FetchError.PassageDoesNotExist) }
        if parsedPassage.verse_start < 0 { return (false, FetchError.PassageDoesNotExist) }
        
        return (true, nil)
    }

    func fetchPassage(parsedPassage: ParsedPassage, translation: String="kjv") throws -> Passage {
        let (valid, error) = validatePassage(parsedPassage)
        if !valid { throw error! }

        let store = HeartversesStore(sqliteURL: NSBundle.mainBundle().URLForResource("Heartverses", withExtension: "sqlite")!)
        var passage = Passage(parsedPassage: parsedPassage)
        
        let fetchedVerses: [NSManagedObject] = store.findVersesInChapter(translation, bookSlug: parsedPassage.book, chapter: parsedPassage.chapter_start) as! [NSManagedObject]
        if fetchedVerses.isEmpty { throw FetchError.PassageDoesNotExist }
        if (parsedPassage.verse_start == 1 && parsedPassage.verse_end >= fetchedVerses.count) { passage.verse_start = 0; passage.verse_end = 0 }
        
        if parsedPassage.verse_start == 0 {
            for v in fetchedVerses {
                let verse = Verse(book: parsedPassage.book, chapter: parsedPassage.chapter_start, number: v.valueForKey("number") as! Int, text: v.valueForKey("text") as! String)
                passage.verses.append(verse)
            }
        } else {
            for i in parsedPassage.verse_start...parsedPassage.verse_end {
                if i >= fetchedVerses.count {
                    passage.verse_end = i
                    break
                }

                let verse = Verse(book: parsedPassage.book, chapter: parsedPassage.chapter_start, number: i, text: fetchedVerses[i-1].valueForKey("text") as! String)
                passage.verses.append(verse)
            }
        }

        if passage.verses.isEmpty { throw FetchError.PassageDoesNotExist }

        return passage
    }
    
    func fetchVerseText(rawPassage: String) -> String {
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
    
    func parsePassage(passage: String) -> String {
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
    
    private func URLStringFromPassage(passage: String) -> String {
        let comps = passage.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: " :"))
        return "/kjv/\(comps[0])/\(comps[1])/\(comps[2])"
    }
    
    private func removeSpacesFromRawPassage(rawPassage: String) -> String {
        if let spacesRegex: NSRegularExpression = try? NSRegularExpression(pattern: " ", options: NSRegularExpressionOptions.CaseInsensitive) {
            return spacesRegex.stringByReplacingMatchesInString(rawPassage, options: NSMatchingOptions.ReportCompletion, range: NSMakeRange(0, rawPassage.characters.count), withTemplate: "")
        }
        return "failure"
    }
}