//
//  TabTests.swift
//  uSurfTests
//
//  Created by Matthew Jagiela on 8/4/22.
//  Copyright © 2022 Matthew Jagiela. All rights reserved.
//

import UIKit
import Foundation
import XCTest

@testable import uSurf

class TabTests: XCTestCase {
    
    let handler = TabHandler()
    
    func testStoringTabs() {
        let tab = TabData(name: "Apple", url: "https://apple.com")
        do {
            try self.handler.addiPhoneTab(tab: tab)
        } catch {
            XCTFail("Failed to save tab with error: \(error)")
        }
    }
    
    func testReadingTab() {
        do {
            let fetchedTab = try handler.getiPhoneTabs()
            XCTAssertFalse(fetchedTab.isEmpty, "False")
            XCTAssertEqual(fetchedTab.first!.name, "Apple")
        } catch {
            XCTFail("Failed to fetch tabs with error: \(error)")
        }
    }
}
