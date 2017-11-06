//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.

import Foundation
import CoreData

extension UserVerse {

  @NSManaged var book: String?
  @NSManaged var chapter: NSNumber?
  @NSManaged var number: NSNumber?
  @NSManaged var text: String?
  @NSManaged var views: NSNumber?
  @NSManaged var passage: UserPassage?
  @NSManaged var selected: Bool

}
