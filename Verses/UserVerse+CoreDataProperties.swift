//
//  UserVerse+CoreDataProperties.swift
//  Verses
//
//  Created by Isaac Williams on 12/14/15.
//  Copyright © 2015 The Williams Family. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension UserVerse {

    @NSManaged var book: String?
    @NSManaged var chapter: NSNumber?
    @NSManaged var number: NSNumber?
    @NSManaged var text: String?
    @NSManaged var views: NSNumber?
    @NSManaged var passage: UserPassage?

}