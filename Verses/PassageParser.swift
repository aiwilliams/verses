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
        print(comps)

        if hasNumberedBook(passage) {
            book = convertToSlug("\(comps[0]) \(comps[1])")
            comps.removeAtIndex(0)
            comps.removeAtIndex(0)
        } else {
            book = convertToSlug(comps[0])
            comps.removeAtIndex(0)
        }

        result.book = book
        result.chapter_start = Int(comps[0])!
        if containsChaptersOnly(passage) {
            print("chapter only")
            result.chapter_end = Int(comps[1])!
            result.verse_start = 1
            result.verse_end = 1
        } else if containsVerseRange(passage) {
            print("contains verse range")
            result.chapter_end = Int(comps[0])!
            result.verse_start = Int(comps[1])!
            result.verse_end = Int(comps[2])!
        } else {
            print("single verse")
            result.chapter_end = Int(comps[0])!
            result.verse_start = Int(comps[1])!
            result.verse_end = Int(comps[1])!
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
    
    func containsChaptersOnly(passage: String) -> Bool {
        return passage.containsString("-") && !passage.containsString(":")
    }
    
    func containsVerseRange(passage: String) -> Bool {
        return passage.containsString(":") && passage.containsString("-")
    }
    
    func hasNumberedBook(passage: String) -> Bool {
        let zero = passage.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: " :-"))[0]
        if (Int(zero) != nil) {
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
