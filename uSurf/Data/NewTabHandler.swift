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
}

class TabHandler {
    final fileprivate var iPhoneTabIdentifier = "iPhoneNewTabs"
    final fileprivate var iPadTabIdentifier = "iPadNewTabs"
    private var iPhoneTabs: [TabData] = []
    private var iPadTabs: [TabData] = []
    
    init() {
        do {
            self.iPhoneTabs = try self.getiPhoneTabs()
            self.iPadTabs = try self.getiPadTabs()
        } catch {
            self.iPhoneTabs = []
            self.iPadTabs = []
        }
    }
    
    
    // MARK: - Data Manipulation
    
    func addiPhoneTab(tab: TabData) throws {
        do {
            self.iPhoneTabs = try self.getiPhoneTabs()
            self.iPhoneTabs.append(tab)
            try self.storeiPhoneTabs()
        } catch {
            throw error
        }
    }
    
    func addiPadTab(tab: TabData) throws {
        do {
            self.iPadTabs = try self.getiPadTabs()
            self.iPadTabs.append(tab)
            try self.storeiPadTabs()
        } catch {
            throw error
        }
    }
    // MARK: - Setters
    
    func storeiPhoneTabs() throws {
        do {
            let encodedData = try JSONEncoder().encode(self.iPhoneTabs)
            NSUbiquitousKeyValueStore.default.set(encodedData, forKey: self.iPhoneTabIdentifier)
        } catch {
            throw TabErrors.encodingError
        }
    }
    
    func storeiPadTabs() throws {
        do {
            let encodedData = try JSONEncoder().encode(self.iPadTabs)
            NSUbiquitousKeyValueStore.default.set(encodedData, forKey: self.iPadTabIdentifier)
        } catch {
            throw TabErrors.encodingError
        }
    }
    
    // MARK: - Getters
    func getiPhoneTabs() throws -> [TabData] {
        guard let tabData = NSUbiquitousKeyValueStore.default.data(forKey: iPhoneTabIdentifier) else { return [] }
        do {
            let decodedTabs = try JSONDecoder().decode([TabData].self, from: tabData)
            return decodedTabs
        } catch {
            throw TabErrors.decodingError
        }
    }
    
    func getiPadTabs() throws -> [TabData] {
        guard let tabData = NSUbiquitousKeyValueStore.default.data(forKey: iPadTabIdentifier) else { return [] }
        do {
            let decodedTabs = try JSONDecoder().decode([TabData].self, from: tabData)
            return decodedTabs
        } catch {
            throw TabErrors.decodingError
        }
    }
}
