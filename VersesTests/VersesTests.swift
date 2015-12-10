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
        XCTAssertEqual("John", result.book)
        XCTAssertEqual(1, result.chapter_start)
        XCTAssertEqual(1, result.chapter_end)
        XCTAssertEqual(1, result.verse_start)
        XCTAssertEqual(1, result.verse_end)

        result = parser.parse("John 1:2")
        XCTAssertEqual("John", result.book)
        XCTAssertEqual(1, result.chapter_start)
        XCTAssertEqual(1, result.chapter_end)
        XCTAssertEqual(2, result.verse_start)
        XCTAssertEqual(2, result.verse_end)
        
        result = parser.parse("Revelation 3:12")
        XCTAssertEqual("Revelation", result.book)
        XCTAssertEqual(3, result.chapter_start)
        XCTAssertEqual(3, result.chapter_end)
        XCTAssertEqual(12, result.verse_start)
        XCTAssertEqual(12, result.verse_end)
    }
    
    func testParseLowercaseBookName() {
        let result = parser.parse("genesis 1:1")
        XCTAssertEqual("Genesis", result.book)
        XCTAssertEqual(1, result.chapter_start)
        XCTAssertEqual(1, result.chapter_end)
        XCTAssertEqual(1, result.verse_start)
        XCTAssertEqual(1, result.verse_end)
    }
    
    func testParseRange() {
        var result = parser.parse("genesis 1:1-4")
        XCTAssertEqual("Genesis", result.book)
        XCTAssertEqual(1, result.chapter_start)
        XCTAssertEqual(1, result.chapter_end)
        XCTAssertEqual(1, result.verse_start)
        XCTAssertEqual(4, result.verse_end)
        
        result = parser.parse("john 1:3-19")
        XCTAssertEqual("John", result.book)
        XCTAssertEqual(1, result.chapter_start)
        XCTAssertEqual(1, result.chapter_end)
        XCTAssertEqual(3, result.verse_start)
        XCTAssertEqual(19, result.verse_end)
    }
    
    func testParseChapterRange() {
        let result = parser.parse("psalms 1-3")
        XCTAssertEqual("Psalms", result.book)
        XCTAssertEqual(1, result.chapter_start)
        XCTAssertEqual(3, result.chapter_end)
        XCTAssertEqual(1, result.verse_start)
        XCTAssertEqual(1, result.verse_end)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
