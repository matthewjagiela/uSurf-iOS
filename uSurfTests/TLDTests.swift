//
//  TLDTests.swift
//  uSurfTests
//
//  Created by Matthew Jagiela on 2/27/22.
//  Copyright © 2022 Matthew Jagiela. All rights reserved.
//

import UIKit
import XCTest
@testable import uSurf

class TLDTests: XCTestCase {
    func testTLDDecoding() {
        let safeDomains = uSurf.TLDHandler.validDomains.count
        let internetExpectation = expectation(description: "TLD")
        uSurf.TLDHandler.fetchTLD { success in
            if success {
                XCTAssertTrue(uSurf.TLDHandler.validDomains.count > safeDomains)
            } else {
                XCTFail("Decoding Error")
            }
            internetExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
}
