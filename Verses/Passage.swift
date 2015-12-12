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
        let comps = parsedPassage.book.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "-"))
        if comps.count == 2 {
            return "\(comps[0]) \(comps[1].capitalizedString) \(parsedPassage.chapter_start):\(parsedPassage.verse_start)"
        } else {
            return "\(comps[0].capitalizedString) \(parsedPassage.chapter_start):\(parsedPassage.verse_start)"
        }
    }
}