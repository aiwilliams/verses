//
//  BiblePassage.swift
//  verses
//
//  Created by Adam Williams on 7/26/14.
//  Copyright (c) 2014 The Williams Family. All rights reserved.
//

import Foundation
import CoreData

class BiblePassage : NSManagedObject {
  @NSManaged var translation : String
  @NSManaged var passage: String
  @NSManaged var content : String
}

class BibliaAPI : NSObject {
  let managedObjectContext: NSManagedObjectContext
  let requestManager: AFHTTPRequestOperationManager

  let apiKey = "fd37d8f28e95d3be8cb4fbc37e15e18e"
  let parseUrl = "http://api.biblia.com/v1/bible/parse"
  let contentUrl = "http://api.biblia.com/v1/bible/content/ASV.txt.json"

  init(moc : NSManagedObjectContext) {
    managedObjectContext = moc
    requestManager = AFHTTPRequestOperationManager()
    requestManager.responseSerializer = AFJSONResponseSerializer()
  }

  func parsePassage(passage: String, completion: (String) -> (Void), failure: (String) -> (Void)) {
    let parameters = ["passage": passage, "key": apiKey]
    requestManager.GET(parseUrl, parameters: parameters,
      success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
        let passage = responseObject.valueForKey("passage") as NSString
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
    let parameters = ["passage": passage, "key": apiKey]
    requestManager.GET(contentUrl, parameters: parameters,
      success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
        completion(responseObject.valueForKey("text") as NSString)
      },
      failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
        failure("Sorry! I have failed you :/")
      }
    )
  }

  func loadPassage(passage: String, completion: (BiblePassage) -> (Void), failure: (String) -> (Void) ) {
    parsePassage(passage,
      completion: { (normalizedPassage: String) in
        self.loadContentOfPassage(normalizedPassage,
          completion: { (content) in
            let biblePassage = NSEntityDescription.insertNewObjectForEntityForName("BiblePassage", inManagedObjectContext: self.managedObjectContext) as BiblePassage
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

}