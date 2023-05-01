//
//  VersionHandlerTests.swift
//  uSurfTests
//
//  Created by Matthew Jagiela on 3/17/20.
//  Copyright © 2020 Matthew Jagiela. All rights reserved.
//

import UIKit
import XCTest
import Combine
import uAppsLibrary

class VersionHandlerTests: XCTestCase {
    
    var subscriptions: Set<AnyCancellable> = []
    
    let handler = InternetLabelsManager()
    func test_changes_populated() {
        let appInfo = AppInformation()
        XCTAssert(!appInfo.getChanges().isEmpty)
    }
    
    func test_newest_version_combine() {
        let internetExpectation = expectation(description: "InternetLabels")
        handler.fetchLabels().receive(on: RunLoop.main).sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error): XCTFail("Failure with error: \(error)")
            case .finished: print("finished")
            }
            
        }, receiveValue: { info in
            XCTAssertNotNil(info.uAppsNews)
            XCTAssertNotNil(info.uSurfVersion)
            internetExpectation.fulfill()
            
        }).store(in: &subscriptions)
        waitForExpectations(timeout: 5)
    }
    
    func test_newest_version_legacy() {
        let internetExpectation = expectation(description: "InternetLabels")
        handler.legacyFetchLabels { (info) in
            XCTAssertNotNil(info.uAppsNews)
            XCTAssertNotNil(info.uSurfVersion)
            internetExpectation.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
}
