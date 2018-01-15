import Foundation
import CoreData

// Before running this script, set NSReadOnlyPersistentStoreOption to false in persistentStoreCoordinator.
// Remember to set it back to true when you're done, though; the app will crash on actual iDevices if you
// don't! See issue https://github.com/aiwilliams/verses/issues/21 and commit
// https://github.com/aiwilliams/verses/commit/8be61a83e13c81a14e6f3d20283a967fbd093eed

let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
let store = HeartversesStore(sqliteURL: documentsDirectory.appendingPathComponent("Heartverses.sqlite"))

func normalizeBookName(_ bookName: String) -> String {
  let comps = bookName.components(separatedBy: " ")
  if comps.count == 1 {
    return comps[0].lowercased()
  } else if comps.count == 2 {
    return "\(comps[0])-\(comps[1].lowercased())"
  } else {
    return "\(comps[0].lowercased())-\(comps[1].lowercased())-\(comps[2].lowercased())"
  }
}

func importKJV(sourcePath: String) {
  var json: JSON!

  do {
    let jsonData = try Data(contentsOf: URL(fileURLWithPath: sourcePath), options: .mappedIfSafe)
    json = try JSON(data: jsonData)
  } catch let error {
    print(error.localizedDescription)
  }

  let translation = "kjv"
  var books = [Int:NSManagedObject]()
  var chapters = [Int:Array<Int>]()

  for (_,object):(String, JSON) in json {
    switch object["model"] {
    case "bible.book":
      let bookName = object["fields"]["slug"].stringValue
      books[object["pk"].intValue] = store.findOrCreateBook(name: bookName, translation: translation)
    case "bible.chapter":
      chapters[object["pk"].intValue] = [object["fields"]["book"].intValue, object["fields"]["number"].intValue]
    case "bible.verse":
      let chapter = chapters[object["fields"]["chapter"].intValue]!
      let book = books[chapter[0]]!
      store.addVerse(book: book, chapter: chapter[1], number: object["fields"]["number"].intValue, text: object["fields"]["text"].stringValue)
    default:
      print(object)
    }
  }
}

func importNKJV(sourcePath: String) {
  var json: JSON!

  do {
    let jsonData = try Data(contentsOf: URL(fileURLWithPath: sourcePath), options: .mappedIfSafe)
    json = try JSON(data: jsonData)
  } catch let error {
    print(error.localizedDescription)
  }

  let translation = "nkjv"

  for (_, bookObject):(String, JSON) in json {
    let bookName = normalizeBookName(bookObject["name"].stringValue)
    let book = store.findOrCreateBook(name: bookName, translation: translation)
    for (_, chapterObject):(String, JSON) in bookObject["chapters"] {
      let chapter = chapterObject["num"].intValue
      for (_, verseObject):(String, JSON) in chapterObject["verses"] {
        store.addVerse(book: book, chapter: chapter, number: verseObject["num"].intValue, text: verseObject["text"].stringValue)
      }
    }
  }
}

importKJV(sourcePath: "/Users/isaacjw/Desktop/kjv_bible.json")
importNKJV(sourcePath: "/Users/isaacjw/Desktop/nkjv_bible.json")
