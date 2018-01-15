import Foundation
import CoreData

class HeartversesStore {

  let url: URL

  enum StoreError: Error {
    case passageDoesNotExistInStore
  }

  init(sqliteURL: URL) {
    url = sqliteURL
  }

  func addBook(name: String, translation: String) -> NSManagedObject {
    let entity = NSEntityDescription.entity(forEntityName: "Book", in: managedObjectContext)!
    let book = newObject(entity)
    book.setValue(name, forKey: "name")
    book.setValue(translation, forKey: "translation")
    saveContext()
    return book
  }

  func addVerse(book: NSManagedObject, chapterNumber: Int, number: Int, text: String) {
    let verse = newObject("Verse")
    verse.setValue(book, forKey: "book")
    verse.setValue(chapterNumber, forKey: "chapter")
    verse.setValue(number, forKey: "number")
    verse.setValue(text, forKey: "text")
    self.saveContext()
  }

  func findBook(name: String, translation: String) -> NSManagedObject? {
    return findObject("Book", format: "name == %@ and translation == %@", name as AnyObject, translation as AnyObject)
  }

  func findOrCreateBook(name: String, translation: String) -> NSManagedObject {
    if let existingBook = findBook(name: name, translation: translation) {
      return existingBook
    } else {
      return addBook(name: name, translation: translation)
    }
  }

  func findVerses(bookName: String, chapter: Int, translation: String) -> [NSManagedObject] {
    guard let book = findBook(name: bookName, translation: translation) else { return [] }

    let entity = NSEntityDescription.entity(forEntityName: "Verse", in: managedObjectContext)!
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.name!)
    fetchRequest.predicate = NSPredicate(format: "book == %@ and chapter == %@", argumentArray: [book, chapter])

    do {
      if let verses = try managedObjectContext.fetch(fetchRequest) as? [NSManagedObject] {
        return verses
      } else {
        return []
      }
    } catch let error as NSError {
      print("Could not find chapter. Error: \(error), \(error.userInfo)")
      return []
    }
  }

  func findVerse(bookName: String, translation: String, chapter: Int, number: Int) -> NSManagedObject? {
    guard let book = findBook(name: bookName, translation: translation) else { return nil }
    return findObject("Verse", format: "book == %@ and chapter == %@ and number == %@", book, chapter as AnyObject, number as AnyObject)
  }

  func newObject(_ entity: NSEntityDescription) -> NSManagedObject {
    return NSManagedObject(entity: entity, insertInto: self.managedObjectContext)
  }

  func newObject(_ entityName: String) -> NSManagedObject {
    let entity = NSEntityDescription.entity(forEntityName: entityName, in: self.managedObjectContext)!
    return newObject(entity)
  }

  func findObject(_ entityName: String, format: String, _ arguments: AnyObject...) -> NSManagedObject? {
    let entity = NSEntityDescription.entity(forEntityName: entityName, in: self.managedObjectContext)!
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.name!)
    fetchRequest.predicate = NSPredicate(format: format, argumentArray: arguments)
    do {
      let results = try self.managedObjectContext.fetch(fetchRequest)
      if results.isEmpty {
        return nil
      } else {
        return results.first as? NSManagedObject
      }
    } catch let error as NSError {
      print("Could not find book \(error), \(error.userInfo)")
      return nil
    }
  }

  lazy var managedObjectModel: NSManagedObjectModel = {
    let modelURL = Bundle.main.url(forResource: "Heartverses", withExtension: "momd")!
    return NSManagedObjectModel(contentsOf: modelURL)!
  }()

  lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
    let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
    var failureReason = "There was an error creating or loading the application's saved data."
    do {
      try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: self.url, options: [NSReadOnlyPersistentStoreOption: true])
    } catch {
      var dict = [String: AnyObject]()
      dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
      dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject

      dict[NSUnderlyingErrorKey] = error as NSError
      let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
      // Replace this with code to handle the error appropriately.
      // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
      abort()
    }

    return coordinator
  }()

  lazy var managedObjectContext: NSManagedObjectContext = {
    let coordinator = self.persistentStoreCoordinator
    var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    managedObjectContext.persistentStoreCoordinator = coordinator
    return managedObjectContext
  }()

  func saveContext () {
    if managedObjectContext.hasChanges {
      do {
        try managedObjectContext.save()
      } catch {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        let nserror = error as NSError
        NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
        abort()
      }
    }
  }

}
