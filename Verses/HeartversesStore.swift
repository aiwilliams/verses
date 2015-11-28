import Foundation
import CoreData

class HeartversesStore {
    
    func addVerse(book: NSManagedObject, chapter: Int, number: Int, text: String) {
        let moc = self.managedObjectContext
        let entity = NSEntityDescription.entityForName("Verse", inManagedObjectContext: moc)!
        let verse = NSManagedObject(entity: entity, insertIntoManagedObjectContext: moc)
        verse.setValue(book, forKey: "book")
        verse.setValue(chapter, forKey: "chapter")
        verse.setValue(number, forKey: "number")
        verse.setValue(text, forKey: "text")

        do {
            try moc.save()
        } catch let error as NSError {
            print("Could not save verse \(error), \(error.userInfo)")
        }
    }

    func findBook(slug: String, translation: String) -> NSManagedObject {
        var book: NSManagedObject! = nil
        
        let moc = self.managedObjectContext
        let entity = NSEntityDescription.entityForName("Book", inManagedObjectContext: moc)!

        let fetchRequest = NSFetchRequest(entityName: entity.name!)
        fetchRequest.predicate = NSPredicate(format: "name == %@ and translation == %@", slug, translation)
        do {
            let books = try moc.executeFetchRequest(fetchRequest)
            if books.isEmpty {
                book = NSManagedObject(entity: entity, insertIntoManagedObjectContext: moc)
                book.setValue(slug, forKey: "name")
                book.setValue(translation, forKey: "translation")
            } else {
                book = books.first as! NSManagedObject
            }
        } catch let error as NSError {
            print("Could not find book \(error), \(error.userInfo)")
        }

        return book
    }
    
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        print(urls)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource("Heartverses", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Heartverses.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
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
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
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