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

  func parsePassage(passage: String, completion: (String?) -> (Void)) {
    let parameters = ["passage": passage, "key": apiKey]
    requestManager.GET(parseUrl, parameters: parameters,
      success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
        completion(responseObject.valueForKey("passage") as? NSString)
      },
      failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
        completion(nil)
      }
    )
  }

  func loadContentOfPassage(passage: String, completion: (String?) -> (Void)) {
    let parameters = ["passage": passage, "key": apiKey]
    requestManager.GET(contentUrl, parameters: parameters,
      success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
        completion(responseObject.valueForKey("text") as? NSString)
      },
      failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
        completion(nil)
      }
    )
  }

  // Loads the passage. If it cannot be parsed or it's content loaded, the BiblePassage will be nil.
  func loadPassage(passage: String, completion: (BiblePassage?) -> (Void) ) {
    parsePassage(passage, completion: { (normalizedPassage: String?) in
      if let nonblankPassage = normalizedPassage {
        self.loadContentOfPassage(nonblankPassage, completion: { (content) in
          let biblePassage = NSEntityDescription.insertNewObjectForEntityForName("BiblePassage", inManagedObjectContext: self.managedObjectContext) as BiblePassage
          if let nonblankContent = content {
            biblePassage.translation = "ASV"
            biblePassage.passage = nonblankPassage
            biblePassage.content = nonblankContent
            
            var error: NSError?
            self.managedObjectContext.save(&error)
            
            completion(biblePassage)
          } else {
            completion(nil)
          }
        })
      } else {
        completion(nil)
      }
    })
  }

}