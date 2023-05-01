//
//  BookmarkCoreDataTests.swift
//  uSurfTests
//
//  Created by Matthew Jagiela on 5/1/23.
//  Copyright © 2023 Matthew Jagiela. All rights reserved.
//

import XCTest

@testable import uSurf

class BookmarkCoreDataTests: XCTestCase {
    
    let coreData = CoreDataHandler()
    var identifyingBookmark: BookmarkData = BookmarkData(name: "", url: "")
    
    override func setUp() async throws {
        try coreData.deleteAllBookmarks()
    }
    
    func addBookmark() {
        identifyingBookmark = BookmarkData(name: "Apple", url: "https://apple.com")
        do {
            try self.coreData.createBookmark(from: identifyingBookmark)
            XCTAssertTrue(try coreData.getBookmarkData().count == 1)
        } catch {
            XCTFail("Failure to add bookmark \(error)")
        }
        
        let bookmark = BookmarkData(name: "uApps", url: "https://uAppsiOS.com")
        do {
            try self.coreData.createBookmark(from: bookmark)
            XCTAssertTrue(try coreData.getBookmarkData().count == 2)
        } catch {
            XCTFail("Failure to add bookmark \(error)")
        }
    }
    
    func testGettingAllBookmarks() {
        do {
            var bookmarks = try coreData.getBookmarkData()
            if bookmarks.isEmpty {
                self.addBookmark()
                bookmarks = try coreData.getBookmarkData()
            }
            XCTAssertTrue(bookmarks.count == 2)
        } catch {
            XCTFail("Error getting all bookmarks \(error)")
        }
    }
    
    func testGettingIndividualBookmark() {
        do {
            if try coreData.getBookmarkData().isEmpty {
                self.addBookmark()
            }
            
            let foundBookmark = try coreData.getBookmark(withID: identifyingBookmark.identifier)
            
            XCTAssertNotNil(foundBookmark)
            XCTAssertTrue(foundBookmark?.nickname == "Apple")
            XCTAssertTrue(foundBookmark?.webURL == "https://apple.com")
        } catch {
            XCTFail("Error getting bookmark \(error)")
        }
    }
    
    override func tearDown() async throws {
        try coreData.deleteAllBookmarks()
    }

}
