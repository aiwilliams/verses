import Foundation

class Regex {
  let internalExpression: NSRegularExpression?
  let pattern: String

  init(_ pattern: String) {
    self.pattern = pattern
    do {
      self.internalExpression = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
    } catch {
      self.internalExpression = nil
      print("yo dawg i heard you like crashing the app")
    }
  }

  func test(_ input: String) -> Bool {
    let matches = self.internalExpression!.matches(in: input, options: NSRegularExpression.MatchingOptions.withTransparentBounds, range:NSMakeRange(0, input.count))
    return matches.count > 0
  }
}

/**
 ParsedPassage represents the constituent parts of a passage string and is not necessarily a valid bible passage. It is not the responsiblity of the PassageParser to provide valid passages. This design allows the parser to avoid the responsibility of knowing what makes a valid passage, though it must know something of book names to support abbreviated names such as "Jn" for "John".
 */
struct ParsedPassage {
  var book = "undefined"
  var chapter_start = -1
  var chapter_end = -1
  var verse_start = -1
  var verse_end = -1
}

class PassageParser {
  enum ParseError: Error {
    case ambiguousBookName
    case invalidRange
  }

  let slugs = ["genesis", "exodus", "leviticus", "numbers", "deuteronomy", "joshua", "judges", "ruth", "1-samuel", "2-samuel", "1-kings", "2-kings", "1-chronicles", "2-chronicles", "ezra", "nehemiah", "esther", "job", "psalms", "proverbs", "ecclesiastes", "song-of-solomon", "isaiah", "jeremiah", "lamentations", "ezekiel", "daniel", "hosea", "joel", "amos", "obadiah", "jonah", "micah", "nahum", "habakkuk", "zephaniah", "haggai", "zechariah", "malachi", "matthew", "mark", "luke", "john", "acts", "romans", "1-corinthians", "2-corinthians", "galatians", "ephesians", "philippians", "colossians", "1-thessalonians", "2-thessalonians", "1-timothy", "2-timothy", "titus", "philemon", "hebrews", "james", "1-peter", "2-peter", "1-john", "2-john", "3-john", "jude", "revelation"]

  let conventionalAbbrevs: [String: String] = ["sos": "song-of-solomon", "jn": "john", "jo": "john", "phil": "philippians", "eph": "ephesians"]

  func parse(_ passage: String) throws -> ParsedPassage {
    var parsedPassage = ParsedPassage()
    var comps = passage.components(separatedBy: CharacterSet(charactersIn: " :-"))
    var book: String!

    if containsTripleTokenName(passage) {
      book = convertToSlug("\(comps[0]) \(comps[1]) \(comps[2])")
      comps.remove(at: 0); comps.remove(at: 0); comps.remove(at: 0)
    } else if containsTwoTokenName(passage) {
      book = convertToSlug("\(comps[0]) \(comps[1])")
      comps.remove(at: 0); comps.remove(at: 0)
    } else if containsSingleTokenName(passage) {
      book = convertToSlug(comps[0])
      comps.remove(at: 0)
    } else {
      return try validatePassage(parsedPassage)
    }

    parsedPassage.book = book

    var index = 0
    for i in comps {
      let x: Int? = Int(i)
      if x == nil {
        comps.remove(at: index)
      }
      index += 1
    }

    if !comps.isEmpty {
      parsedPassage.chapter_start = Int(comps[0])!
      if containsChapterRange(passage) {
        parsedPassage.chapter_end = Int(comps[1])!
        parsedPassage.verse_start = 0
        parsedPassage.verse_end = 0
      } else if containsChapterOnly(passage) {
        parsedPassage.chapter_end = Int(comps[0])!
        parsedPassage.verse_start = 0
        parsedPassage.verse_end = 0
      } else if containsVerseRange(passage) {
        parsedPassage.chapter_end = Int(comps[0])!
        parsedPassage.verse_start = Int(comps[1])!
        parsedPassage.verse_end = Int(comps[2])!
      } else if containsSingleVerse(passage) {
        parsedPassage.chapter_end = Int(comps[0])!
        parsedPassage.verse_start = Int(comps[1])!
        parsedPassage.verse_end = Int(comps[1])!
      }
    }

    return try validatePassage(parsedPassage)
  }

  func convertToSlug(_ bookName: String) -> String {
    for (abbrev, slug) in conventionalAbbrevs {
      if abbrev == bookName.lowercased() { return slug }
    }

    var wildcardBookName = ""
    let bookNameComps = bookName.components(separatedBy: CharacterSet(charactersIn: " "))

    for char in bookNameComps.joined(separator: "-") {
      wildcardBookName.append(Character(".")); wildcardBookName.append(Character("?"))
      wildcardBookName.append(char)
    }
    wildcardBookName.append(Character(".")); wildcardBookName.append(Character("?"))

    let reg = Regex(wildcardBookName)

    var possibleSlugs: Array<String> = []
    for i in slugs {
      if i == bookName.lowercased() { return i }

      if reg.test(i) {
        possibleSlugs += [i]
      }
    }

    if possibleSlugs.count == 1 {
      return possibleSlugs[0]
    } else {
      return "ambiguous"
    }
  }

  func containsChapterRange(_ passage: String) -> Bool {
    return Regex("^\\d?[^\\d]+ \\d+-\\d+$").test(passage)
  }

  func containsChapterOnly(_ passage: String) -> Bool {
    return Regex("^\\d?[^\\d]+ \\d+$").test(passage)
  }

  func containsVerseRange(_ passage: String) -> Bool {
    return Regex("^\\d?[^\\d]+ \\d+:\\d+-\\d+$").test(passage)
  }

  func containsSingleVerse(_ passage: String) -> Bool {
    return Regex("^\\d?[^\\d]+ \\d+:\\d+$").test(passage)
  }

  func containsSingleTokenName(_ passage: String) -> Bool {
    return Regex("^[\\w]+ ?(\\d{1,3})?(:\\d+)?(-\\d+)?$").test(passage)
  }

  func containsTwoTokenName(_ passage: String) -> Bool {
    return Regex("^[\\d\\w]+ [A-Za-z]+ ?(\\d{1,3})?(:\\d+)?(-\\d+)?$").test(passage)
  }

  func containsTripleTokenName(_ passage: String) -> Bool {
    return Regex("^[A-Za-z]+ [A-Za-z]+ [A-Za-z]+ ?(\\d{1,3})?(:\\d+)?(-\\d+)?$").test(passage)
  }

  func validatePassage(_ parsedPassage: ParsedPassage) throws -> ParsedPassage {
    if parsedPassage.book == "ambiguous" {
      throw ParseError.ambiguousBookName
    } else if parsedPassage.verse_start > parsedPassage.verse_end ||
      parsedPassage.chapter_start > parsedPassage.chapter_end ||
      parsedPassage.chapter_start < 1 ||
      parsedPassage.verse_start < 0 {
      throw ParseError.invalidRange
    } else {
      return parsedPassage
    }
  }
}
