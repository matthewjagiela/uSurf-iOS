//
//  NewTabHandler.swift
//  uSurf
//
//  Created by Matthew Jagiela on 8/3/22.
//  Copyright © 2022 Matthew Jagiela. All rights reserved.
//

import Foundation
import UIKit

enum TabErrors: Error {
    case encodingError
    case decodingError
}

/// A container for custom tab information
struct TabData: Codable, Hashable {
    var name: String
    var url: String
    var image: Data?
    var identifier = UUID()
}

class TabHandler {
    var database = CoreDataHandler()
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
    // MARK: - Add Data
    
    func addTabData(tab: TabData) {
        self.database.createTab(tabData: tab)
        
        do {
            let iCloudTab = TabData(name: tab.name, url: tab.url)
            if UIDevice.current.userInterfaceIdiom == .pad {
                try self.addiPadTab(tab: tab)
            } else {
                try self.addiPhoneTab(tab: tab)
            }
        } catch {
            print("Error setting tabs to iCloud \(error.localizedDescription)")
        }
    }
    
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
    
    // MARK: - Set Data on iCloud
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
    
    //MARK: - Deletion
    
    func deleteLocalTabs(tabs: [TabData], completion: @escaping (Error?) -> Void) {
        database.deleteTabs(tabs: tabs) { error in
            if let error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    func deleteAllTabs(completion: @escaping (Error?) -> Void) {
        database.deleteAllTabs { error in
            if let error {
                completion(error)
            } else {
                completion(nil)
            }
        }
        
        //Clear the network tabs
    }
    
    // MARK: - Getters
    
    func getLocalTabs() -> [TabData] {
        return database.getTabData()
    }
    
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
