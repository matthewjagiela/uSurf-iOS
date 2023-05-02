//
//  HomeViewModel.swift
//  uSurf
//
//  Created by Matthew Jagiela on 4/24/22.
//  Copyright © 2022 Matthew Jagiela. All rights reserved.
//

import Foundation
import UIKit

class HomeViewModel {
    let iCloud = iCloudHandler()
    let savedData = SavedDataHandler()
    let tabHandler = TabHandler()
    let coreData = CoreDataHandler()
    init() { }
    
    func addBookmark(name: String?, address: String?) throws {
        guard let name = name, let address = address else { return } // TODO: Throw error
        try self.coreData.createBookmark(from: BookmarkData(name: name, url: address))
    }
    
    func addToTabs(url: URL?) {
        guard let url = url else { return } // TODO: Throw error
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            iCloud.addToiPadTabArray(url.absoluteString)
        } else {
            iCloud.addToiPhoneTabArray(url.absoluteString)
        }
    }
    
    func addTab(name: String, url: String, image: Data) throws {
        let tab = TabData(name: name, url: url, image: image)
        tabHandler.addTabData(tab: tab)
    }
    
    func addToHistory(url: URL?) {
        guard let url = url else {
            return
        }
        savedData.addToHistoryArray(url.absoluteString)
        savedData.setLastViewedPage(lastPage: url.absoluteString)
    }
}
