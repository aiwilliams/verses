import Foundation
import CoreData

var APIURL: String = "http://localhost/v1/passage"

class HeartversesAPI {
  enum FetchError: Error {
    case passageDoesNotExist
  }

  let store = HeartversesStore(sqliteURL: Bundle.main.url(forResource: "Heartverses", withExtension: "sqlite")!)

  func fetchPassage(_ parsedPassage: ParsedPassage, translation: String = "kjv") throws -> Passage {
    if let passage = fetchPassageFromCache(parsedPassage, translation: translation) {
      return passage
    } else if let passage = fetchPassageFromServer(parsedPassage, translation: translation) {
      return passage
    } else {
      throw FetchError.passageDoesNotExist
    }
  }

  private func fetchPassageFromServer(_ parsedPassage: ParsedPassage, translation: String) -> Passage? {
    let session = URLSession(configuration: URLSessionConfiguration.default)
    let task = session.dataTask(with: URL(string: APIURL)!) { (data, response, error) in
      if let d = data {
        print(d)
      } else {
        print("no data")
      }
    }
    task.resume()
    return nil
  }

  private func fetchPassageFromCache(_ parsedPassage: ParsedPassage, translation: String) -> Passage? {
    var passage = Passage(parsedPassage: parsedPassage)

    let fetchedVerses = store.findVerses(bookName: parsedPassage.book, chapter: parsedPassage.chapter_start, translation: translation)
    guard !fetchedVerses.isEmpty else { return nil }

    // TODO: Make this clear!
    // The following code is meant to determine whether the range is equivalent to a complete chapter and if so, cause the function to just return all found verses.
    if (parsedPassage.verse_start == 1 && parsedPassage.verse_end >= fetchedVerses.count) {
      passage.verse_start = 0
      passage.verse_end = 0
    }

    if parsedPassage.verse_start == 0 {
      for v in fetchedVerses {
        let verse = Verse(book: parsedPassage.book, chapter: parsedPassage.chapter_start, number: v.value(forKey: "number") as! Int, text: v.value(forKey: "text") as! String)
        passage.verses.append(verse)
      }
    } else {
      for i in parsedPassage.verse_start...parsedPassage.verse_end {
        if i > fetchedVerses.count {
          passage.verse_end = i - 1
          break
        }

        let verse = Verse(book: parsedPassage.book, chapter: parsedPassage.chapter_start, number: i, text: fetchedVerses[i-1].value(forKey: "text") as! String)
        passage.verses.append(verse)
      }
    }

    if passage.verses.isEmpty { return nil }

    return passage
  }

  func fetchVerseText(_ rawPassage: String) -> String {
    let parsedPassage = parsePassage(rawPassage)
    let passageURL = URLStringFromPassage(parsedPassage)
    let verseURL = URL(string: APIURL + passageURL)!
    let verseData: Data? = try? Data(contentsOf: verseURL)
    var verseJSON: AnyObject? = nil

    do {
      verseJSON = try JSONSerialization.jsonObject(with: verseData!, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject
    } catch _ as NSError {
      print("could not serialize verse text JSON from HeartVersesAPI")
    }

    if let data = verseJSON as? NSDictionary {
      if let verses = data["verses"] as? NSArray {
        if let topVerse = verses[0] as? NSDictionary {
          if let text = topVerse["text"] as? String {
            return text
          }
        }
      }
    }

    return "failure"
  }

  func parsePassage(_ passage: String) -> String {
    let parseURL = URL(string: APIURL + "/parse/" + removeSpacesFromRawPassage(passage))
    let parseData: Data? = try? Data(contentsOf: parseURL!)
    var parseJSON: AnyObject? = nil

    if parseData == nil { return "failure" } // they put in an out-of-bounds passage or something dumb

    do {
      parseJSON = try JSONSerialization.jsonObject(with: parseData!, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject
    } catch _ as NSError {
      print("could not serialize parsed passage JSON from HeartVersesAPI")
    }

    if let data = parseJSON as? NSDictionary {
      if let book = data["book"] as? String {
        if let chapter = data["chapter"] as? Int {
          if let verse = data["verse"] as? Int {
            return "\(book) \(chapter):\(verse)"
          }
        }
      }
    }

    return "failure"
  }

  fileprivate func URLStringFromPassage(_ passage: String) -> String {
    let comps = passage.components(separatedBy: CharacterSet(charactersIn: " :"))
    return "/kjv/\(comps[0])/\(comps[1])/\(comps[2])"
  }

  fileprivate func removeSpacesFromRawPassage(_ rawPassage: String) -> String {
    if let spacesRegex: NSRegularExpression = try? NSRegularExpression(pattern: " ", options: NSRegularExpression.Options.caseInsensitive) {
      return spacesRegex.stringByReplacingMatches(in: rawPassage, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSMakeRange(0, rawPassage.count), withTemplate: "")
    }
    return "failure"
  }
}
