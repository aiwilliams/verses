//
//  UserPassage+CoreDataProperties.swift
//  Verses
//
//  Created by Isaac Williams on 2/15/16.
//  Copyright © 2016 The Williams Family. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension UserPassage {

    @NSManaged var memorized: NSNumber?
    @NSManaged var reference: String?
    @NSManaged var verses: NSOrderedSet?
    @NSManaged var selectedVerses: [UserVerse]

}
