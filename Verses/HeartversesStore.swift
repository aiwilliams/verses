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
    
    func addVerse(_ book: NSManagedObject, chapter: Int, number: Int, text: String) {
        let verse = newObject("Verse")
        verse.setValue(book, forKey: "book")
        verse.setValue(chapter, forKey: "chapter")
        verse.setValue(number, forKey: "number")
        verse.setValue(text, forKey: "text")
        self.saveContext()
    }

    func findBook(_ translation: String, slug: String) -> NSManagedObject {
        let book = findObject("Book", format: "name == %@ and translation == %@", slug as AnyObject, translation as AnyObject)
        if book.objectID.isTemporaryID {
            book.setValue(slug, forKey: "name")
            book.setValue(translation, forKey: "translation")
            saveContext()
        }
        return book
    }
    
    func findVersesInChapter(_ translation: String, bookSlug: String, chapter: Int) -> [AnyObject] {
        let book = findBook(translation, slug: bookSlug)
        let entity = NSEntityDescription.entity(forEntityName: "Verse", in: self.managedObjectContext)!
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.name!)
        fetchRequest.predicate = NSPredicate(format: "book == %@ and chapter == %@", argumentArray: [book, chapter])
        do {
            let verses = try self.managedObjectContext.fetch(fetchRequest)
            if !verses.isEmpty {
                return verses as [AnyObject]
            }
        } catch let error as NSError {
            print("Could not find chapter. Error: \(error), \(error.userInfo)")
        }
        return []
    }

    func findVerse(_ translation: String, bookSlug: String, chapter: Int, number: Int) -> NSManagedObject {
        let book = findBook(translation, slug: bookSlug)

        let verse = findObject("Verse", format: "book == %@ and chapter == %@ and number == %@", book, chapter as AnyObject, number as AnyObject)
        return verse
    }
    
    func newObject(_ entity: NSEntityDescription) -> NSManagedObject {
        return NSManagedObject(entity: entity, insertInto: self.managedObjectContext)
    }
    
    func newObject(_ entityName: String) -> NSManagedObject {
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: self.managedObjectContext)!
        return newObject(entity)
    }
    
    func findObject(_ entityName: String, format: String, _ arguments: AnyObject...) -> NSManagedObject {
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: self.managedObjectContext)!
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.name!)
        fetchRequest.predicate = NSPredicate(format: format, argumentArray: arguments)
        do {
            let results = try self.managedObjectContext.fetch(fetchRequest)
            if !results.isEmpty {
                return results.first as! NSManagedObject
            }
        } catch let error as NSError {
            print("Could not find book \(error), \(error.userInfo)")
        }
        return newObject(entity)
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
