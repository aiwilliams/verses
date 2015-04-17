import Foundation
import CoreData

class BiblePassage : NSManagedObject {
  @NSManaged var translation : String?
  @NSManaged var passage: String?
  @NSManaged var content : String?
}

class BiblePassageStore : NSObject {
    let managedObjectContext: NSManagedObjectContext

    init(moc : NSManagedObjectContext) {
        managedObjectContext = moc
    }

    func passages() -> [BiblePassage]? {
        let entityDescription: NSEntityDescription = NSEntityDescription.entityForName("BiblePassage", inManagedObjectContext: managedObjectContext)!
        let request: NSFetchRequest = NSFetchRequest()
        request.entity = entityDescription

        var error: NSError?
        return managedObjectContext.executeFetchRequest(request, error: &error) as! [BiblePassage]?
    }

    // For now, return the last passage...
    func activeBiblePassage() -> BiblePassage? {
        let passages = self.passages()!
        return passages.last
    }

    func biblePassageForVerseReference(verseReference: String) -> BiblePassage? {
        if let p = passages() {
            for biblePassage in p {
                if biblePassage.passage == verseReference {
                    return biblePassage
                }
            }
        }
        return nil
    }
}

protocol RemoteAPI {
    var parseURL : String { get }
    var loadURL : String { get }
    func initializeRequestManager(AFHTTPRequestOperationManager)
    func parseParameters(passage: String) -> Dictionary<String, String>
    func loadParameters(passage: String) -> Dictionary<String, String>
}

class VerseSourceAPI : NSObject {
    let managedObjectContext: NSManagedObjectContext
    let requestManager: AFHTTPRequestOperationManager
    let remoteAPI: RemoteAPI

    init(api : RemoteAPI, moc : NSManagedObjectContext) {
        remoteAPI = api
        managedObjectContext = moc
        requestManager = AFHTTPRequestOperationManager()
        requestManager.responseSerializer = AFJSONResponseSerializer() as AFHTTPResponseSerializer

        remoteAPI.initializeRequestManager(requestManager)
    }

    func parsePassage(passage: String, completion: (String) -> (Void), failure: (String) -> (Void)) {
        requestManager.GET(remoteAPI.parseURL, parameters: remoteAPI.parseParameters(passage),
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                let passage = responseObject.valueForKey("passage") as! String
                if passage == "" {
                    failure("That's not a valid verse! Try again.")
                } else {
                    completion(passage)
                }
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                failure("Sorry! I have failed you :/")
            }
        )
    }

    func loadContentOfPassage(passage: String, completion: (String) -> (Void), failure: (String) -> (Void)) {
        requestManager.GET(remoteAPI.loadURL, parameters: remoteAPI.loadParameters(passage),
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                completion(responseObject.valueForKey("text") as! String)
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                failure("Sorry! I have failed you :/")
            }
        )
    }

    func loadPassage(passage: String, completion: (BiblePassage) -> (Void), failure: (String) -> (Void) ) {
//        loadFakePassage(completion)
         parsePassage(passage,
             completion: { (normalizedPassage: String) in
                 self.loadContentOfPassage(normalizedPassage,
                     completion: { (content) in
                         let biblePassage = NSEntityDescription.insertNewObjectForEntityForName("BiblePassage", inManagedObjectContext: self.managedObjectContext) as! BiblePassage
                         biblePassage.translation = "ASV"
                         biblePassage.passage = normalizedPassage
                         biblePassage.content = content

                         var error: NSError?
                         self.managedObjectContext.save(&error)

                         completion(biblePassage)
                     },
                     failure: failure)
             },
             failure: failure)
    }

    // For those times when the servers just aren't working.
    func loadFakePassage(completion: (BiblePassage) -> (Void)) {
        let biblePassage = NSEntityDescription.insertNewObjectForEntityForName("BiblePassage", inManagedObjectContext: self.managedObjectContext) as! BiblePassage
        biblePassage.translation = "ESV"
        biblePassage.passage = "Genesis 1:1-5"
        biblePassage.content = "In the beginning, God created the heavens and the earth. The earth was without form and void, and darkness was over the face of the deep. And the Spirit of God was hovering over the face of the waters. And God said, \"Let there be light,\" and there was light. And God saw that the light was good. And God separated the light from the darkness. God called the light Day, and the darkness he called Night. And there was evening and there was morning, the first day."

        var error: NSError?
        self.managedObjectContext.save(&error)

        completion(biblePassage)
    }
}

class BibliaAPI : RemoteAPI {
    let apiKey = "fd37d8f28e95d3be8cb4fbc37e15e18e"

    var parseURL : String { get { return "http://api.biblia.com/v1/bible/parse" } }
    var loadURL : String { get { return "http://api.biblia.com/v1/bible/content/ASV.txt.json" } }

    func initializeRequestManager(_: AFHTTPRequestOperationManager) {
    }

    func parseParameters(passage: String) -> Dictionary<String, String> {
        return ["passage": passage, "key": apiKey]
    }

    func loadParameters(passage: String) -> Dictionary<String, String> {
        return ["passage": passage, "key": apiKey]
    }
}