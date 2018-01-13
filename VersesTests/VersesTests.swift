import XCTest
@testable import Verses

class VersesTests: XCTestCase {
    
    let parser = PassageParser()
        
    func testParseAlreadyCleanVerse() {
        var result = try! parser.parse("John 1:1")
        XCTAssertEqual("john", result.book)
        XCTAssertEqual(1, result.chapter_start)
        XCTAssertEqual(1, result.chapter_end)
        XCTAssertEqual(1, result.verse_start)
        XCTAssertEqual(1, result.verse_end)

        result = try! parser.parse("John 1:2")
        XCTAssertEqual("john", result.book)
        XCTAssertEqual(1, result.chapter_start)
        XCTAssertEqual(1, result.chapter_end)
        XCTAssertEqual(2, result.verse_start)
        XCTAssertEqual(2, result.verse_end)
        
        result = try! parser.parse("Revelation 3:12")
        XCTAssertEqual("revelation", result.book)
        XCTAssertEqual(3, result.chapter_start)
        XCTAssertEqual(3, result.chapter_end)
        XCTAssertEqual(12, result.verse_start)
        XCTAssertEqual(12, result.verse_end)
    }
    
    func testParseLowercaseBookName() {
        let result = try! parser.parse("genesis 1:1")
        XCTAssertEqual("genesis", result.book)
        XCTAssertEqual(1, result.chapter_start)
        XCTAssertEqual(1, result.chapter_end)
        XCTAssertEqual(1, result.verse_start)
        XCTAssertEqual(1, result.verse_end)
    }
    
    func testParseRange() {
        var result = try! parser.parse("genesis 1:1-4")
        XCTAssertEqual("genesis", result.book)
        XCTAssertEqual(1, result.chapter_start)
        XCTAssertEqual(1, result.chapter_end)
        XCTAssertEqual(1, result.verse_start)
        XCTAssertEqual(4, result.verse_end)
        
        result = try! parser.parse("john 1:3-19")
        XCTAssertEqual("john", result.book)
        XCTAssertEqual(1, result.chapter_start)
        XCTAssertEqual(1, result.chapter_end)
        XCTAssertEqual(3, result.verse_start)
        XCTAssertEqual(19, result.verse_end)
    }
    
    func testParseChapterNoVerse() {
        let result = try! parser.parse("psalms 1")
        XCTAssertEqual("psalms", result.book)
        XCTAssertEqual(1, result.chapter_start)
        XCTAssertEqual(1, result.chapter_end)
        XCTAssertEqual(0, result.verse_start)
        XCTAssertEqual(0, result.verse_end)
    }
    
    func testParseChapterRange() {
        let result = try! parser.parse("psalms 1-3")
        XCTAssertEqual("psalms", result.book)
        XCTAssertEqual(1, result.chapter_start)
        XCTAssertEqual(3, result.chapter_end)
        XCTAssertEqual(0, result.verse_start)
        XCTAssertEqual(0, result.verse_end)
    }
    
    func testParseIntoProperSlug() {
        let result = try! parser.parse("2 Samuel 1:3")
        XCTAssertEqual("2-samuel", result.book)
        XCTAssertEqual(1, result.chapter_start)
        XCTAssertEqual(1, result.chapter_end)
        XCTAssertEqual(3, result.verse_start)
        XCTAssertEqual(3, result.verse_end)
    }

    func testParseNumberedBookVerseRange() {
        let result = try! parser.parse("2 Samuel 1:3-4")
        XCTAssertEqual("2-samuel", result.book)
        XCTAssertEqual(1, result.chapter_start)
        XCTAssertEqual(1, result.chapter_end)
        XCTAssertEqual(3, result.verse_start)
        XCTAssertEqual(4, result.verse_end)
    }
    
    func testParseNumberedBookChapterRange() {
        let result = try! parser.parse("2 Samuel 1-4")
        XCTAssertEqual("2-samuel", result.book)
        XCTAssertEqual(1, result.chapter_start)
        XCTAssertEqual(4, result.chapter_end)
        XCTAssertEqual(0, result.verse_start)
        XCTAssertEqual(0, result.verse_end)
    }
    
    func testParseSlangBookTitleSingleVerse() {
        let result = try! parser.parse("jam 1:1")
        XCTAssertEqual("james", result.book)
        XCTAssertEqual(1, result.chapter_start)
        XCTAssertEqual(1, result.chapter_end)
        XCTAssertEqual(1, result.verse_start)
        XCTAssertEqual(1, result.verse_end)
    }
    
    func testParseSlangBookTitleVerseRange() {
        let result = try! parser.parse("gen 1:1-3")
        XCTAssertEqual("genesis", result.book)
        XCTAssertEqual(1, result.chapter_start)
        XCTAssertEqual(1, result.chapter_end)
        XCTAssertEqual(1, result.verse_start)
        XCTAssertEqual(3, result.verse_end)
    }
    
    func testParseSlangBookTitleChapterRange() {
        let result = try! parser.parse("gen 1-3")
        XCTAssertEqual("genesis", result.book)
        XCTAssertEqual(1, result.chapter_start)
        XCTAssertEqual(3, result.chapter_end)
        XCTAssertEqual(0, result.verse_start)
        XCTAssertEqual(0, result.verse_end)
    }
    
    func testParseSlangNumberedBook() {
        let result = try! parser.parse("2sam 3:4")
        XCTAssertEqual("2-samuel", result.book)
        XCTAssertEqual(3, result.chapter_start)
        XCTAssertEqual(3, result.chapter_end)
        XCTAssertEqual(4, result.verse_start)
        XCTAssertEqual(4, result.verse_end)
    }
    
    func testParseSlangNumberedBookVariation2() {
        let result = try! parser.parse("2sa 3:4")
        XCTAssertEqual("2-samuel", result.book)
        XCTAssertEqual(3, result.chapter_start)
        XCTAssertEqual(3, result.chapter_end)
        XCTAssertEqual(4, result.verse_start)
        XCTAssertEqual(4, result.verse_end)
    }
    
    func testParseSlangNumberedBookVariation3() {
        let result = try! parser.parse("1thes 3:4")
        XCTAssertEqual("1-thessalonians", result.book)
        XCTAssertEqual(3, result.chapter_start)
        XCTAssertEqual(3, result.chapter_end)
        XCTAssertEqual(4, result.verse_start)
        XCTAssertEqual(4, result.verse_end)
    }
    
    func testParseSlangNumberedBookVariation4() {
        let result = try! parser.parse("2 sam 3:4")
        XCTAssertEqual("2-samuel", result.book)
        XCTAssertEqual(3, result.chapter_start)
        XCTAssertEqual(3, result.chapter_end)
        XCTAssertEqual(4, result.verse_start)
        XCTAssertEqual(4, result.verse_end)
    }
    
    func testAmbiguousBookName() {
      XCTAssertThrowsError(try parser.parse("j 3:4"), "Ambiguous book") { (e) in
        XCTAssertEqual(e as? PassageParser.ParseError, PassageParser.ParseError.ambiguousBookName)
      }
    }
    
    func testSongOfSolomon() {
        let result = try! parser.parse("song of solomon 4:4")
        XCTAssertEqual("song-of-solomon", result.book)
        XCTAssertEqual(4, result.chapter_start)
        XCTAssertEqual(4, result.chapter_end)
        XCTAssertEqual(4, result.verse_start)
        XCTAssertEqual(4, result.verse_end)
    }
    
    func testSongOfSolomonSlang() {
        let result = try! parser.parse("song 4:4")
        XCTAssertEqual("song-of-solomon", result.book)
        XCTAssertEqual(4, result.chapter_start)
        XCTAssertEqual(4, result.chapter_end)
        XCTAssertEqual(4, result.verse_start)
        XCTAssertEqual(4, result.verse_end)
    }
    
    func testSongOfSolomonSlangVariation2() {
        let result = try! parser.parse("sos 4:4")
        XCTAssertEqual("song-of-solomon", result.book)
        XCTAssertEqual(4, result.chapter_start)
        XCTAssertEqual(4, result.chapter_end)
        XCTAssertEqual(4, result.verse_start)
        XCTAssertEqual(4, result.verse_end)
    }
    
    func testSongOfSolomonSlangVariation3() {
        let result = try! parser.parse("song of 4:4")
        XCTAssertEqual("song-of-solomon", result.book)
        XCTAssertEqual(4, result.chapter_start)
        XCTAssertEqual(4, result.chapter_end)
        XCTAssertEqual(4, result.verse_start)
        XCTAssertEqual(4, result.verse_end)
    }
    
    func testSongOfSolomonVerseRange() {
        let result = try! parser.parse("song of solomon 4:4-5")
        XCTAssertEqual("song-of-solomon", result.book)
        XCTAssertEqual(4, result.chapter_start)
        XCTAssertEqual(4, result.chapter_end)
        XCTAssertEqual(4, result.verse_start)
        XCTAssertEqual(5, result.verse_end)
    }
}
