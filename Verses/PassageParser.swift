//
//  VerseParser.swift
//  Verses
//
//  Created by Isaac Williams on 12/8/15.
//  Copyright © 2015 The Williams Family. All rights reserved.
//

import Foundation

class Regex {
    let internalExpression: NSRegularExpression?
    let pattern: String
    
    init(_ pattern: String) {
        self.pattern = pattern
        do {
            self.internalExpression = try NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.CaseInsensitive)
        } catch {
            self.internalExpression = nil
            print("yo dawg i heard you like crashing the app")
        }
    }
    
    func test(input: String) -> Bool {
        let matches = self.internalExpression!.matchesInString(input, options: NSMatchingOptions.WithTransparentBounds, range:NSMakeRange(0, input.characters.count))
        return matches.count > 0
    }
}

struct ParsedPassage {
    var book = "undefined"
    var chapter_start = -1
    var chapter_end = -1
    var verse_start = -1
    var verse_end = -1
}

class PassageParser {
    let slugs = ["genesis", "exodus", "leviticus", "numbers", "deuteronomy", "joshua", "judges", "ruth", "1-samuel", "2-samuel", "1-kings", "2-kings", "1-chronicles", "2-chronicles", "ezra", "nehemiah", "esther", "job", "psalms", "proverbs", "ecclesiastes", "song-of-solomon", "isaiah", "jeremiah", "lamentations", "ezekiel", "daniel", "hosea", "joel", "amos", "obadiah", "jonah", "micah", "nahum", "habakkuk", "zephaniah", "haggai", "zechariah", "malachi", "matthew", "mark", "luke", "john", "acts", "romans", "1-corinthians", "2-corinthians", "galatians", "ephesians", "philippians", "colossians", "1-thessalonians", "2-thessalonians", "1-timothy", "2-timothy", "titus", "philemon", "hebrews", "james", "1-peter", "2-peter", "1-john", "2-john", "3-john", "jude", "revelation"]
    
    let conventionalAbbrevs: [String: String] = ["sos": "song-of-solomon", "jn": "john", "jo": "john", "phil": "philippians"]

    func parse(passage: String) -> ParsedPassage {
        var result = ParsedPassage()
        var comps = passage.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: " :-"))
        var book: String!

        print(passage)
        print(containsTwoTokenName(passage))
        print(containsTripleWordName(passage))
        if containsTwoTokenName(passage) {
            book = convertToSlug("\(comps[0]) \(comps[1])")
            comps.removeAtIndex(0); comps.removeAtIndex(0)
        } else if containsTripleWordName(passage) {
            book = convertToSlug("\(comps[0]) \(comps[1]) \(comps[2])")
            comps.removeAtIndex(0); comps.removeAtIndex(0); comps.removeAtIndex(0)
        } else {
            book = convertToSlug(comps[0])
            comps.removeAtIndex(0)
        }

        result.book = book
        
        var index = 0
        print(comps)
        for i in comps {
            let x: Int? = Int(i)
            if x == nil {
                comps.removeAtIndex(index)
            }
            ++index
        }

        if !comps.isEmpty {
            result.chapter_start = Int(comps[0])!
            if containsChapterRange(passage) {
                result.chapter_end = Int(comps[1])!
                result.verse_start = 0
                result.verse_end = 0
            } else if containsChapterOnly(passage) {
                result.chapter_end = Int(comps[0])!
                result.verse_start = 0
                result.verse_end = 0
            } else if containsVerseRange(passage) {
                result.chapter_end = Int(comps[0])!
                result.verse_start = Int(comps[1])!
                result.verse_end = Int(comps[2])!
            } else if containsSingleVerse(passage) {
                result.chapter_end = Int(comps[0])!
                result.verse_start = Int(comps[1])!
                result.verse_end = Int(comps[1])!
            }
        }

        return result
    }
    
    func convertToSlug(bookName: String) -> String {
        for (abbrev, slug) in conventionalAbbrevs {
            if abbrev == bookName.lowercaseString { return slug }
        }
        
        var wildcardBookName = ""
        let bookNameComps = bookName.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: " "))
        
        for char in bookNameComps.joinWithSeparator("-").characters {
            wildcardBookName.append(Character(".")); wildcardBookName.append(Character("?"))
            wildcardBookName.append(char)
        }
        wildcardBookName.append(Character(".")); wildcardBookName.append(Character("?"))
        
        let reg = Regex(wildcardBookName)
        
        var possibleSlugs: Array<String> = []
        for i in slugs {
            if i == bookName.lowercaseString { return i }

            if reg.test(i) {
                possibleSlugs += [i]
            }
        }
        
        if possibleSlugs.count == 1 {
            return possibleSlugs[0]
        } else {
            return "ambiguous"
        }
    }
    
    func containsChapterRange(passage: String) -> Bool {
        return Regex("^\\d?[^\\d]+ \\d+-\\d+$").test(passage)
    }
    
    func containsChapterOnly(passage: String) -> Bool {
        return Regex("^\\d?[^\\d]+ \\d+$").test(passage)
    }
    
    func containsVerseRange(passage: String) -> Bool {
        return Regex("^\\d?[^\\d]+ \\d+:\\d+-\\d+$").test(passage)
    }
    
    func containsSingleVerse(passage: String) -> Bool {
        return Regex("^\\d?[^\\d]+ \\d+:\\d+$").test(passage)
    }
    
    func containsTwoTokenName(passage: String) -> Bool {
        return Regex("^[\\d\\w]+ [A-Za-z]+ ?(\\d{1,3})?(:\\d+)?(-\\d+)?$").test(passage)
    }
    
    func containsTripleWordName(passage: String) -> Bool {
        return Regex("^[\\w]+ [\\w]+ [\\w]+ ?(\\d{1,3})?(:\\d+)?(-\\d+)?$").test(passage)
    }
}
