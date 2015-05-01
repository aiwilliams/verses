import Foundation
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AddVerseDelegate {
    var window: UIWindow?
    
    lazy var managedObjectContext: NSManagedObjectContext = self.initialManagedObjectContext()
    lazy var biblePassageStore: BiblePassageStore = { return BiblePassageStore(moc: self.managedObjectContext) }()
    lazy var verseSourceApi: VerseSourceAPI = { return VerseSourceAPI(api: BibliaAPI(), moc: self.managedObjectContext) }()
    
    func applicationDidFinishLaunching(application: UIApplication) {
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: UIUserNotificationType.Sound | UIUserNotificationType.Alert | UIUserNotificationType.Badge, categories: nil))
    }
    
    func applicationWillResignActive(application: UIApplication) {
        if biblePassageStore.passages()?.count == 1 {
            exportToTodayApp(biblePassageStore.activeBiblePassage!)
        }
        
        if self.biblePassageStore.activeBiblePassage == nil {
            clearTodayApp()
        }
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        application.applicationIconBadgeNumber = 0
        
        // TODO: Reload notifications
        // Reload reminder messages
        let settingsTableViewController = SettingsTableViewController()
//        settingsTableViewController.rebuildNotifications()
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        let navigationController = window?.rootViewController as! UINavigationController
        
        if url.host! == "verse" {
            if let openedURL = url.pathComponents {
                let verseReference = openedURL[1] as! String
                navigationController.popToRootViewControllerAnimated(false)
                let homeTableViewController = navigationController.viewControllers[0] as! UITableViewController
                // I think we need a custom controller for the home view, so that when we prepare for segue, we can access the versestableview...
                homeTableViewController.performSegueWithIdentifier("versesTableSegue", sender: self)
                
                //                let viewControllers = navigationController.viewControllers!
                //                if let versesTableViewController = viewControllers.last as? VersesTableViewController {
                //                    versesTableViewController.biblePassage = biblePassageStore.biblePassageForVerseReference(verseReference)
                //                }
            }
        } else if url.host! == "addverse" {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let addVerseNavigationController = storyboard.instantiateViewControllerWithIdentifier("addVerse") as! UINavigationController
            addVerseNavigationController.modalTransitionStyle = .CoverVertical
            let addVerseController = addVerseNavigationController.childViewControllers[0] as! AddVerseViewController
            addVerseController.delegate = self
            self.window!.rootViewController!.presentViewController(addVerseNavigationController, animated: true, completion: nil)
        }
        
        return true
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        let navigationController = window?.rootViewController as! UINavigationController
        navigationController.popToRootViewControllerAnimated(false)
        let homeTableViewController = navigationController.viewControllers[0] as! UITableViewController
        homeTableViewController.performSegueWithIdentifier("versesTableSegue", sender: self)
        
        // Reload reminder messages
        let settingsTableViewController = SettingsTableViewController()
        settingsTableViewController.rebuildNotifications()
    }
    
    func exportToTodayApp(biblePassage: BiblePassage) {
        let sharedDefaults = NSUserDefaults(suiteName: "group.thewilliams.verses")!
        sharedDefaults.setObject(biblePassage.passage, forKey: "VerseReference")
        sharedDefaults.setObject(biblePassage.content, forKey: "VerseContent")
        sharedDefaults.setBool(biblePassageStore.passages() != nil, forKey: "ContainsVerses")
        
        sharedDefaults.synchronize()
    }
    
    func clearTodayApp() {
        let sharedDefaults = NSUserDefaults(suiteName: "group.thewilliams.verses")!
        sharedDefaults.setBool(false, forKey: "ContainsVerses")
        sharedDefaults.synchronize()
    }
    
    func initialManagedObjectContext() -> NSManagedObjectContext {
        let modelUrl = NSBundle.mainBundle().URLForResource("UserData", withExtension: "momd")!
        let mom = NSManagedObjectModel(contentsOfURL: modelUrl)!
        let fileManager = NSFileManager.defaultManager()
        let libraryUrl: NSURL = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last as! NSURL
        let url = libraryUrl.URLByAppendingPathComponent("Example.storedata")
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: mom)
        
        var error: NSError?
        coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error)
        
        let managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }
    
    func addVerseCanceled() {
        self.window!.rootViewController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func verseAdded(passage: BiblePassage) {
        self.window!.rootViewController!.dismissViewControllerAnimated(true, completion: nil)
    }
}