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
    case iCloudError
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
    
    init() throws {
        do {
            self.iPhoneTabs = try self.getiPhoneTabs()
            self.iPadTabs = try self.getiPadTabs()
        } catch {
            throw error
        }
    }
    
    
    // MARK: - Setters
    
    // MARK: - Getters
    func getiPhoneTabs() throws -> [Tab] {
        guard let tabData = NSUbiquitousKeyValueStore.default.data(forKey: iPhoneTabIdentifier) else { throw TabErrors.iCloudError }
        do {
            let decodedTabs = try JSONDecoder().decode([Tab].self, from: tabData)
            return decodedTabs
        } catch {
            throw TabErrors.decodingError
        }
    }
    
    func getiPadTabs() throws -> [Tab] {
        guard let tabData = NSUbiquitousKeyValueStore.default.data(forKey: iPadTabIdentifier) else { throw TabErrors.iCloudError }
        do {
            let decodedTabs = try JSONDecoder().decode([Tab].self, from: tabData)
            return decodedTabs
        } catch {
            throw TabErrors.decodingError
        }
    }
}
