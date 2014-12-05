import Foundation
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    lazy var managedObjectContext: NSManagedObjectContext = self.initialManagedObjectContext()
    lazy var biblePassageStore: BiblePassageStore = { return BiblePassageStore(moc: self.managedObjectContext) }()
    
    func applicationDidFinishLaunching(application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }
    
    func applicationWillResignActive(application: UIApplication) {
        if let passage = self.biblePassageStore.activeBiblePassage()? {
            exportToTodayApp(passage)
        }
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        if url.host! == "verse" {
            if let openedURL = url.pathComponents? {
                let verseReference = openedURL[1] as String
                let navigationController = window?.rootViewController? as UINavigationController
                navigationController.popToRootViewControllerAnimated(false)
                let homeTableViewController = navigationController.viewControllers[0] as UITableViewController
                
                homeTableViewController.performSegueWithIdentifier("versesTableSegue", sender: self)
                
                if let versesTableViewController = navigationController.viewControllers.last as? VersesTableViewController {
                    versesTableViewController.biblePassage = biblePassageStore.biblePassageForVerseReference(verseReference)
                }
            }
        }
        
        return true
    }

    func exportToTodayApp(biblePassage: BiblePassage) {
        let sharedDefaults = NSUserDefaults(suiteName: "group.thewilliams.verses")!
        sharedDefaults.setObject(biblePassage.passage, forKey: "VerseReference")
        sharedDefaults.setObject(biblePassage.content, forKey: "VerseContent")
        sharedDefaults.synchronize()
    }
    
    func initialManagedObjectContext() -> NSManagedObjectContext {
        let modelUrl = NSBundle.mainBundle().URLForResource("UserData", withExtension: "momd")!
        let mom = NSManagedObjectModel(contentsOfURL: modelUrl)!
        let fileManager = NSFileManager.defaultManager()
        let libraryUrl: NSURL = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last as NSURL
        let url = libraryUrl.URLByAppendingPathComponent("Example.storedata")
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: mom)
        
        var error: NSError?
        coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error)
        
        let managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }
}