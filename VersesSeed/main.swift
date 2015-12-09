import Foundation
import CoreData

let store = HeartversesStore()
let path = "/Users/isaacjw/Desktop/kjv_bible.json"

var json: JSON!

do {
    let jsonData = try NSData(contentsOfURL: NSURL(fileURLWithPath: path), options: NSDataReadingOptions.DataReadingMappedIfSafe)
    json = JSON(data: jsonData)
} catch let error as NSError {
    print(error.localizedDescription)
}

let translation = "kjv"
var books = [Int:NSManagedObject]()
var chapters = [Int:Array<Int>]()

for (index,object):(String, JSON) in json {
    switch object["model"] {
    case "bible.book":
        let bookSlug = object["fields"]["slug"].stringValue
        books[object["pk"].intValue] = store.findBook(bookSlug, translation: translation)
    case "bible.chapter":
        chapters[object["pk"].intValue] = [object["fields"]["book"].intValue, object["fields"]["number"].intValue]
    case "bible.verse":
        let chapter = chapters[object["fields"]["chapter"].intValue]!
        let book = books[chapter[0]]!
        store.addVerse(book, chapter: chapter[1], number: object["fields"]["number"].intValue, text: object["fields"]["text"].stringValue)
    default:
        print(object)
    }
}