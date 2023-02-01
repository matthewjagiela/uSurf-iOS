//
//  NewTabHandler.swift
//  uSurf
//
//  Created by Matthew Jagiela on 8/3/22.
//  Copyright © 2022 Matthew Jagiela. All rights reserved.
//

import Foundation

enum TabErrors: Error {
    case encodingError
    case decodingError
}

/// A container for custom tab information
struct TabData: Codable, Hashable {
    var name: String
    var url: String
    var image: Data
    var identifier = UUID()
}

class TabHandler {
    var database = CoreDataHandler()
    final fileprivate var iPhoneTabIdentifier = "iPhoneNewTabs"
    final fileprivate var iPadTabIdentifier = "iPadNewTabs"
    private var iPhoneTabs: [TabData] = []
    private var iPadTabs: [TabData] = []
    
    init() {}
    // MARK: - Data Manipulation
    
    func addTabData(tab: TabData) {
        self.database.createTab(tabData: tab)
    }
    
    // MARK: - Getters
    
    func getLocalTabs() -> [TabData] {
        return database.getTabData()
    }
}
