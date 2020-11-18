//
//  VersionHandlerTests.swift
//  uSurfTests
//
//  Created by Matthew Jagiela on 3/17/20.
//  Copyright © 2020 Matthew Jagiela. All rights reserved.
//

import UIKit
import XCTest

class VersionHandlerTests: XCTestCase {
    
    let handler = VersionHandler()
    func test_newest_version() {
        handler.labelsFilled { (info) in
            XCTAssertNotNil(info.uSurfVersion)
            XCTAssertNotEqual(info.uSurfVersion, "")
        }
    }
    func test_uapps_news() {
        handler.labelsFilled { (info) in
            XCTAssertNotNil(info.uAppsNews)
            XCTAssertNotEqual(info.uAppsNews, "")
        }
    }
    func test_changes_populated() {
        XCTAssert(!handler.getUpdateInformation().isEmpty)
    }

}
