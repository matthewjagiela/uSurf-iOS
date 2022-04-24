//
//  HomeViewModel.swift
//  uSurf
//
//  Created by Matthew Jagiela on 4/24/22.
//  Copyright © 2022 Matthew Jagiela. All rights reserved.
//

import Foundation

class HomeViewModel {
    let iCloud = iCloudHandler()
    let savedData = SavedDataHandler()
    init() { }
    
    func addBookmark(name: String?, address: String?) {
        guard let name = name, let address = address else { return } //TODO: Throw error
        self.iCloud.addToBookmarkArray(name: name, address: address)
    }
    
    func addToiPhoneTabs(url: URL?) {
        guard let url = url else { return } //TODO: Throw error
        iCloud.addToiPhoneTabArray(url.absoluteString)
    }
    
    func addToHistory(url: URL?) {
        guard let url = url else {
            return
        }
        savedData.addToHistoryArray(url.absoluteString)
        savedData.setLastViewedPage(lastPage: url.absoluteString)
    }
}
