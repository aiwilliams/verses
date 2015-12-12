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
}