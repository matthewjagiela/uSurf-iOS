//
//  BookmarkTests.swift
//  uSurfTests
//
//  Created by Matthew Jagiela on 4/30/23.
//  Copyright © 2023 Matthew Jagiela. All rights reserved.
//

import UIKit
import XCTest
@testable import uSurf
class FavIconTests: XCTestCase {
    let operation = FavIconOperation()
    func testGetIconURL() async throws {
        let google = "https://google.com"
        if let googleFavURL = operation.getIconURL(domain: google) {
            XCTAssertFalse(googleFavURL.absoluteString.isEmpty)
            print("Google Fav Icon URL = \(googleFavURL.absoluteString)")
        } else {
            XCTFail("Google Fav Icon Nil")
        }
        
        let apple = "https://apple.com"
        if let appleFavURL = operation.getIconURL(domain: apple) {
            XCTAssertFalse(appleFavURL.absoluteString.isEmpty)
            print("AppleFav Icon URL = \(appleFavURL.absoluteString)")
        } else {
            XCTFail("Apple Fav Icon Nil")
        }
        
        let uApps = "https://uAppsiOS.com"
        if let uAppsFavURL = operation.getIconURL(domain: uApps) {
            XCTAssertFalse(uAppsFavURL.absoluteString.isEmpty)
            print("uApps Fav Icon URL = \(uAppsFavURL.absoluteString)")
        } else {
            XCTFail("uApps Fav Icon Nil")
        }
    }
    
    func testGetFavImage() async throws {
        if let google = operation.getIconURL(domain: "https://google.com") {
            let googleIcon = try await operation.getFavIconPNG(from: google)
            XCTAssertNotNil(googleIcon)
        } else { XCTFail("Google Icon URL is NIL") }
        
        if let apple = operation.getIconURL(domain: "https://apple.com") {
            let appleIcon = try await operation.getFavIconPNG(from: apple)
            XCTAssertNotNil(appleIcon)
        } else { XCTFail("Apple Icon URL is NIL") }
        
        if let uApps = operation.getIconURL(domain: "https://uAppsiOS.com") {
            let uAppsIcon = try await operation.getFavIconPNG(from: uApps)
            XCTAssertNotNil(uAppsIcon)
        } else { XCTFail("uApps Icon URL is NIL") }
        
    }
}
