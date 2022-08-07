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

struct Tab: Codable, Hashable {
    var name: String
    var url: String
    var image: Data
}

class TabHandler {
    final fileprivate var iPhoneTabIdentifier = "iPhoneNewTabs"
    final fileprivate var iPadTabIdentifier = "iPadNewTabs"
    var iPhoneTabs: [Tab] = []
    var iPadTabs: [Tab] = []
    
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
    
    func addiPhoneTab(tab: Tab) throws {
        do {
            self.iPhoneTabs = try self.getiPhoneTabs()
            self.iPhoneTabs.append(tab)
            try self.storeiPhoneTabs()
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
    
    // MARK: - Getters
    func getiPhoneTabs() throws -> [Tab] {
        guard let tabData = NSUbiquitousKeyValueStore.default.data(forKey: iPhoneTabIdentifier) else { return [] }
        do {
            let decodedTabs = try JSONDecoder().decode([Tab].self, from: tabData)
            return decodedTabs
        } catch {
            throw TabErrors.decodingError
        }
    }
    
    func getiPadTabs() throws -> [Tab] {
        guard let tabData = NSUbiquitousKeyValueStore.default.data(forKey: iPadTabIdentifier) else { return [] }
        do {
            let decodedTabs = try JSONDecoder().decode([Tab].self, from: tabData)
            return decodedTabs
        } catch {
            throw TabErrors.decodingError
        }
    }
}
