//
//  BookmarkViewModelTests.swift
//  uSurfTests
//
//  Created by Matthew Jagiela on 5/2/23.
//  Copyright © 2023 Matthew Jagiela. All rights reserved.
//

import XCTest

@testable import uSurf

class BookmarkViewModelTests: XCTestCase {
    
    var vm = BookmarkViewModel(coreDataService: MockBookmarkDataFetcher())
    
    func test_filtering_bookmarks_name() {
        let searchText = "goo"
        
        vm.filterBookmarks(searchText: searchText)
        
        XCTAssertTrue(vm.filteredBookmarks.count == 1)
        XCTAssertTrue(vm.filteredBookmarks.first?.name == "Google")
        XCTAssertTrue(vm.filteredBookmarks.first?.url == "https://google.com")
    }
    
    func test_filtering_bookmarks_url() {
        let searchText = "http://youtub"
        
        vm.filterBookmarks(searchText: searchText)
        
        XCTAssertTrue(vm.filteredBookmarks.count == 1)
        XCTAssertTrue(vm.filteredBookmarks.first?.name == "Youtube")
        XCTAssertTrue(vm.filteredBookmarks.first?.url == "http://youtube.com")
    }
    
    func test_filtering_empty_string() {
        let searchText = ""
        
        vm.filterBookmarks(searchText: searchText)
        
        XCTAssertTrue(vm.filteredBookmarks.count == vm.bookmarks.count)
        XCTAssertTrue(vm.filteredBookmarks == vm.bookmarks)
    }
    
    func test_filtering_no_results() {
        let searchText = "Reddit"
        vm.filterBookmarks(searchText: searchText)
        XCTAssertTrue(vm.filteredBookmarks.isEmpty)
    }
    
    // TODO: Make Deletion Test
    
}
