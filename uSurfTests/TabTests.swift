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
    
    func addTab() {
        let newTab = TabData(name: "Apple", url: "https://apple.com", image: Data())
        self.handler.addTabData(tab: newTab)
    }
    
    func testStoringTabs() {
        self.addTab()
        XCTAssertTrue(handler.getLocalTabs().count == 1)
    }
    
    func testReadingTab() {
        self.addTab()
        let tabs = handler.getLocalTabs()
        let tab = tabs.first
        XCTAssertNotNil(tab)
        XCTAssertTrue(tabs.count == 1)
        XCTAssertTrue(tab?.name == "Apple")
        XCTAssertTrue(tab?.url == "https://apple.com")
    }
    
    override func tearDown() {
        handler.deleteAllTabs { error in
            if let error {
                fatalError("error with tab teardown \(error)")
            }
        }
    }
    
    override func setUp(completion: @escaping (Error?) -> Void) {
        self.handler.deleteAllTabs { [weak self] error in
            completion(error)
        }
    }
}
