//
//  Passage+CoreDataProperties.swift
//  Verses
//
//  Created by Isaac Williams on 12/11/15.
//  Copyright © 2015 The Williams Family. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension UserPassage {

    @NSManaged var reference: String?
    @NSManaged var verses: NSOrderedSet?

}
