//
//  VersesTests.swift
//  VersesTests
//
//  Created by Isaac Williams on 11/12/15.
//  Copyright © 2015 The Williams Family. All rights reserved.
//

import XCTest
@testable import Verses

class VersesTests: XCTestCase {
    
    let parser = PassageParser()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testParseAlreadyCleanVerse() {
        var result = parser.parse("John 1:1")
        XCTAssertEqual("john", result.book)
        XCTAssertEqual(1, result.chapter_start)
        XCTAssertEqual(1, result.chapter_end)
        XCTAssertEqual(1, result.verse_start)
        XCTAssertEqual(1, result.verse_end)

        result = parser.parse("John 1:2")
        XCTAssertEqual("john", result.book)
        XCTAssertEqual(1, result.chapter_start)
        XCTAssertEqual(1, result.chapter_end)
        XCTAssertEqual(2, result.verse_start)
        XCTAssertEqual(2, result.verse_end)
        
        result = parser.parse("Revelation 3:12")
        XCTAssertEqual("revelation", result.book)
        XCTAssertEqual(3, result.chapter_start)
        XCTAssertEqual(3, result.chapter_end)
        XCTAssertEqual(12, result.verse_start)
        XCTAssertEqual(12, result.verse_end)
    }
    
    func testParseLowercaseBookName() {
        let result = parser.parse("genesis 1:1")
        XCTAssertEqual("genesis", result.book)
        XCTAssertEqual(1, result.chapter_start)
        XCTAssertEqual(1, result.chapter_end)
        XCTAssertEqual(1, result.verse_start)
        XCTAssertEqual(1, result.verse_end)
    }
    
    func testParseRange() {
        var result = parser.parse("genesis 1:1-4")
        XCTAssertEqual("genesis", result.book)
        XCTAssertEqual(1, result.chapter_start)
        XCTAssertEqual(1, result.chapter_end)
        XCTAssertEqual(1, result.verse_start)
        XCTAssertEqual(4, result.verse_end)
        
        result = parser.parse("john 1:3-19")
        XCTAssertEqual("john", result.book)
        XCTAssertEqual(1, result.chapter_start)
        XCTAssertEqual(1, result.chapter_end)
        XCTAssertEqual(3, result.verse_start)
        XCTAssertEqual(19, result.verse_end)
    }
    
    func testParseChapterNoVerse() {
        let result = parser.parse("psalms 1")
        XCTAssertEqual("psalms", result.book)
        XCTAssertEqual(1, result.chapter_start)
        XCTAssertEqual(1, result.chapter_end)
        XCTAssertEqual(0, result.verse_start)
        XCTAssertEqual(0, result.verse_end)
    }
    
    func testParseChapterRange() {
        let result = parser.parse("psalms 1-3")
        XCTAssertEqual("psalms", result.book)
        XCTAssertEqual(1, result.chapter_start)
        XCTAssertEqual(3, result.chapter_end)
        XCTAssertEqual(0, result.verse_start)
        XCTAssertEqual(0, result.verse_end)
    }
    
    func testParseIntoProperSlug() {
        let result = parser.parse("2 Samuel 1:3")
        XCTAssertEqual("2-samuel", result.book)
        XCTAssertEqual(1, result.chapter_start)
        XCTAssertEqual(1, result.chapter_end)
        XCTAssertEqual(3, result.verse_start)
        XCTAssertEqual(3, result.verse_end)
    }

    func testParseNumberedBookVerseRange() {
        let result = parser.parse("2 Samuel 1:3-4")
        XCTAssertEqual("2-samuel", result.book)
        XCTAssertEqual(1, result.chapter_start)
        XCTAssertEqual(1, result.chapter_end)
        XCTAssertEqual(3, result.verse_start)
        XCTAssertEqual(4, result.verse_end)
    }
    
    func testParseNumberedBookChapterRange() {
        let result = parser.parse("2 Samuel 1-4")
        XCTAssertEqual("2-samuel", result.book)
        XCTAssertEqual(1, result.chapter_start)
        XCTAssertEqual(4, result.chapter_end)
        XCTAssertEqual(0, result.verse_start)
        XCTAssertEqual(0, result.verse_end)
    }
    
    func testParseSlangBookTitleSingleVerse() {
        let result = parser.parse("jam 1:1")
        XCTAssertEqual("james", result.book)
        XCTAssertEqual(1, result.chapter_start)
        XCTAssertEqual(1, result.chapter_end)
        XCTAssertEqual(1, result.verse_start)
        XCTAssertEqual(1, result.verse_end)
    }
    
    func testParseSlangBookTitleVerseRange() {
        let result = parser.parse("gen 1:1-3")
        XCTAssertEqual("genesis", result.book)
        XCTAssertEqual(1, result.chapter_start)
        XCTAssertEqual(1, result.chapter_end)
        XCTAssertEqual(1, result.verse_start)
        XCTAssertEqual(3, result.verse_end)
    }
    
    func testParseSlangBookTitleChapterRange() {
        let result = parser.parse("gen 1-3")
        XCTAssertEqual("genesis", result.book)
        XCTAssertEqual(1, result.chapter_start)
        XCTAssertEqual(3, result.chapter_end)
        XCTAssertEqual(0, result.verse_start)
        XCTAssertEqual(0, result.verse_end)
    }
    
    func testParseSlangNumberedBook() {
        let result = parser.parse("2sam 3:4")
        XCTAssertEqual("2-samuel", result.book)
        XCTAssertEqual(3, result.chapter_start)
        XCTAssertEqual(3, result.chapter_end)
        XCTAssertEqual(4, result.verse_start)
        XCTAssertEqual(4, result.verse_end)
    }
    
    func testParseSlangNumberedBookVariation2() {
        let result = parser.parse("2sa 3:4")
        XCTAssertEqual("2-samuel", result.book)
        XCTAssertEqual(3, result.chapter_start)
        XCTAssertEqual(3, result.chapter_end)
        XCTAssertEqual(4, result.verse_start)
        XCTAssertEqual(4, result.verse_end)
    }
    
    func testParseSlangNumberedBookVariation3() {
        let result = parser.parse("1thes 3:4")
        XCTAssertEqual("1-thessalonians", result.book)
        XCTAssertEqual(3, result.chapter_start)
        XCTAssertEqual(3, result.chapter_end)
        XCTAssertEqual(4, result.verse_start)
        XCTAssertEqual(4, result.verse_end)
    }
    
    func testParseSlangNumberedBookVariation4() {
        let result = parser.parse("2 sam 3:4")
        XCTAssertEqual("2-samuel", result.book)
        XCTAssertEqual(3, result.chapter_start)
        XCTAssertEqual(3, result.chapter_end)
        XCTAssertEqual(4, result.verse_start)
        XCTAssertEqual(4, result.verse_end)
    }
    
    func testAmbiguousBookName() {
        let result = parser.parse("j 3:4")
        XCTAssertEqual("ambiguous", result.book)
        XCTAssertEqual(3, result.chapter_start)
        XCTAssertEqual(3, result.chapter_end)
        XCTAssertEqual(4, result.verse_start)
        XCTAssertEqual(4, result.verse_end)
    }
}
