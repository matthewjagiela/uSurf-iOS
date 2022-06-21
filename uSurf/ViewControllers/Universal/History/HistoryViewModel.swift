//
//  HistoryViewModel.swift
//  uSurf
//
//  Created by Matthew Jagiela on 6/19/22.
//  Copyright © 2022 Matthew Jagiela. All rights reserved.
//

import Foundation

class HistoryViewModel {
    weak var tableDelegate: uAppsTableDelegate?
    var savedData = SavedDataHandler()
    var browserSide: BrowserSide?
    
    var history: [String] = []
    var filteredHistory: [String] = []
    var searchTerm = "" {
        didSet {
            if searchTerm.isEmpty {
                filteredHistory = history
            } else {
                filteredHistory = history.filter {
                    $0.lowercased().contains(searchTerm)
                }
            }
        }
    }
    
    init(browserSide: BrowserSide? = nil) {
        self.browserSide = browserSide
    }
    
    func fetchHistory() {
        guard let historyArray = savedData.getHistoryArray() as? [String] else { return }
        self.history = historyArray
    }
}
