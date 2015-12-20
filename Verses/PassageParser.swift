//
//  VerseParser.swift
//  Verses
//
//  Created by Isaac Williams on 12/8/15.
//  Copyright © 2015 The Williams Family. All rights reserved.
//

import Foundation

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

        print(comps)
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
            } else {
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
        return !passage.containsString(":") && passage.containsString("-")
    }
    
    func containsChapterOnly(passage: String) -> Bool {
        var passageChars = passage.characters

        for i in passageChars {
            if i == ":" {
                passageChars.removeFirst()
                break
            }
            passageChars.removeFirst()
        }

        if passageChars.isEmpty {
            return true
        } else {
            let passageStr = String(passageChars)
            if Int(passageStr) == nil {
                return true
            }

            return false
        }
    }
    
    func containsVerseRange(passage: String) -> Bool {
        if !passage.containsString("-") {
            return false
        }

        var passageChars = passage.characters
        
        for i in passageChars {
            if i == "-" {
                passageChars.removeFirst()
                break
            }
            passageChars.removeFirst()
        }
        
        if passageChars.isEmpty {
            return false
        } else {
            return true
        }
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
    
    func containsOnlyLetters(input: String) -> Bool {
        for chr in input.characters {
            if (!(chr >= "a" && chr <= "z") && !(chr >= "A" && chr <= "Z") ) {
                return false
            }
        }
        return true
    }
}
