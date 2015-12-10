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
    let books = ["genesis":"Genesis", "exodus":"Exodus", "leviticus":"Leviticus", "numbers":"Numbers", "deuteronomy":"Deuteronomy", "joshua":"Joshua", "judges":"Judges", "ruth":"Ruth", "1 samuel":"1 Samuel", "2 samuel":"2 Samuel", "1 kings":"1 Kings", "2 kings":"2 Kings", "1 chronicles":"1 Chronicles", "2 chronicles":"2 Chronicles", "ezra":"Ezra", "nehemiah":"Nehemiah", "esther":"Esther", "job":"Job", "psalms":"Psalms", "proverbs":"Proverbs", "ecclesiastes":"Ecclesiastes", "song of solomon":"Song of Solomon", "isaiah":"Isaiah", "jeremiah":"Jeremiah", "lamentations":"Lamentations", "ezekiel":"Ezekiel", "daniel":"Daniel", "hosea":"Hosea", "joel":"Joel", "amos":"Amos", "obadiah":"Obadiah", "jonah":"Jonah", "micah":"Micah", "nahum":"Nahum", "habakkuk":"Habakkuk", "zephaniah":"Zephaniah", "haggai":"Haggai", "zechariah":"Zechariah", "malachi":"Malachi",
    
        "matthew": "Matthew", "mark":"Mark", "luke":"Luke", "john":"John", "acts":"Acts", "romans":"Romans", "1 corinthians":"1 Corinthians", "2 corinthians":"2, Corinthians", "galatians":"Galatians", "ephesians":"Ephesians", "philippians":"Philippians", "colossians":"Colossians", "1 thessalonians":"1 Thessalonians", "2 thessalonians":"2 Thessalonians", "1 timothy":"1 Timothy", "2 timothy":"2 Timothy", "titus":"Titus", "philemon":"Philemon", "hebrews":"Hebrews", "james":"James", "1 peter":"1 Peter", "2 peter":"2 Peter", "1 john":"1 John", "2 john":"2 John", "3 john":"3 John", "jude":"Jude", "revelation":"Revelation"]
    
    func parse(passage: String) -> ParsedPassage {
        var result = ParsedPassage()
        let comps = passage.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: " :-"))
        print(comps)

        result.book = books[comps[0].lowercaseString]!
        result.chapter_start = Int(comps[1])!
        if containsChaptersOnly(passage) {
            print("chapter only")
            result.chapter_end = Int(comps[2])!
            result.verse_start = 1
            result.verse_end = 1
        } else if containsVerseRange(passage) {
            print("contains verse range")
            result.chapter_end = Int(comps[1])!
            result.verse_start = Int(comps[2])!
            result.verse_end = Int(comps[3])!
        } else {
            print("single verse")
            result.chapter_end = Int(comps[1])!
            result.verse_start = Int(comps[2])!
            result.verse_end = Int(comps[2])!
        }
        return result
    }
    
    func containsChaptersOnly(passage: String) -> Bool {
        return passage.containsString("-") && !passage.containsString(":")
    }
    
    func containsVerseRange(passage: String) -> Bool {
        return passage.containsString(":") && passage.containsString("-")
    }
}
