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
    func parse(passage: String) -> ParsedPassage {
        var result = ParsedPassage()
        var comps = passage.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: " :-"))
        var book: String!

        if hasNumberedBook(passage) {
            book = convertToSlug("\(comps[0]) \(comps[1])")
            comps.removeAtIndex(0)
            comps.removeAtIndex(0)
        } else {
            book = convertToSlug(comps[0])
            comps.removeAtIndex(0)
        }

        result.book = book
        
        var index = 0
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
        let comps = bookName.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: " "))
        if comps.count == 1 {
            return comps[0].lowercaseString
        } else {
            return "\(comps[0])-\(comps[1].lowercaseString)"
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
    
    func hasNumberedBook(passage: String) -> Bool {
        let comps = passage.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: " :-"))
        if comps.count == 1 { return false }

        if (Int(comps[0]) != nil) && (Int(comps[1]) == nil) {
            return true
        } else {
            return false
        }
    }
}
