//
//  Passage.swift
//  Verses
//
//  Created by Isaac Williams on 12/8/15.
//  Copyright © 2015 The Williams Family. All rights reserved.
//

import Foundation

struct Verse {
    let book: String
    let chapter: Int
    let number: Int
    let text: String
}

public struct Passage {
    let parsedPassage: ParsedPassage
    
    var verses = Array<Verse>()
    
    var chapter_start: Int!
    var chapter_end: Int!
    var verse_start: Int!
    var verse_end: Int!

    init(parsedPassage: ParsedPassage) {
        self.parsedPassage = parsedPassage
        
        self.chapter_start = parsedPassage.chapter_start
        self.chapter_end = parsedPassage.chapter_end
        self.verse_start = parsedPassage.verse_start
        self.verse_end = parsedPassage.verse_end
    }
    
    var reference: String {
        var verses = String(self.chapter_start)
        
        if self.verse_start != 0 {
            if self.chapter_start != self.chapter_end {
                verses = verses + ":\(self.verse_start)-\(self.chapter_end):\(self.verse_end)"
            } else {
                verses = verses + ":\(self.verse_start)"
                if self.verse_start != self.verse_end {
                    verses = verses + "-\(self.verse_end)"
                }
            }
        }
        
        let comps = parsedPassage.book.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "-"))

        if comps.count == 2 {
            return "\(comps[0]) \(comps[1].capitalizedString) \(verses)"
        } else {
            return "\(comps[0].capitalizedString) \(verses)"
        }
    }
}