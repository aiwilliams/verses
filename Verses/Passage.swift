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

struct Passage {
    let parsedPassage: ParsedPassage
    
    var verses = Array<Verse>()

    init(parsedPassage: ParsedPassage) {
        self.parsedPassage = parsedPassage
    }
    
    var reference: String {
        var verses = "\(parsedPassage.chapter_start)"
        if parsedPassage.chapter_start != parsedPassage.chapter_end {
            verses = verses + ":\(parsedPassage.verse_start)-\(parsedPassage.chapter_end):\(parsedPassage.verse_end)"
        } else {
            verses = verses + ":\(parsedPassage.verse_start)"
            if parsedPassage.verse_start != parsedPassage.verse_end {
                verses = verses + "-\(parsedPassage.verse_end)"
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