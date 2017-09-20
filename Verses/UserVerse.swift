//
//  Verse.swift
//  Verses
//
//  Created by Isaac Williams on 12/11/15.
//  Copyright © 2015 The Williams Family. All rights reserved.
//

import Foundation
import CoreData

class UserVerse: NSManagedObject {

    var reference: String {
        let comps = self.book!.components(separatedBy: CharacterSet(charactersIn: "-"))
        if comps.count == 2 {
            return "\(comps[0]) \(comps[1].capitalized) \(self.chapter!):\(self.number!)"
        } else {
            return "\(comps[0].capitalized) \(self.chapter!):\(self.number!)"
        }
    }

}
