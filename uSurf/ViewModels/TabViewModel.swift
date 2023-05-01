//
//  TabViewModel.swift
//  uSurf
//
//  Created by Matthew Jagiela on 8/7/22.
//  Copyright © 2022 Matthew Jagiela. All rights reserved.
//

import Foundation
class TabViewModel {
    let tabHandler = TabHandler()
    var tabs: [TabData] = []
    var tableState: TabState = .neutral
    var browserSide: BrowserSide
    
    lazy var selectedTabs = [TabData]()
    lazy var selectedIP = [IndexPath]()
    
    weak var tableViewDelegate: uAppsTableDelegate?
    weak var tabTableDelegate: TabTableDelegate?
    
    init(browserSide: BrowserSide = .single) {
        self.browserSide = browserSide
        self.refresh()
        NotificationCenter.default.addObserver(self, selector: #selector(iCloudUpdate(notification:)), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: NSUbiquitousKeyValueStore.default)
    }
    
    func refresh() {
        do {
            self.tabs = tabHandler.getLocalTabs()
            self.tableViewDelegate?.updateTable()
        }
        
    }
    
    func tabSelected(at indexPath: IndexPath) -> Bool {
        var tabExists = false
        let index = indexPath.row
        let tabData = tabs[index]
        let foundTab = selectedTabs.filter { TabData in
            TabData.identifier == tabData.identifier
        }
        
        if foundTab.isEmpty {
            // does not exist
            selectedTabs.append(tabData)
            selectedIP.append(indexPath)
        } else {
            // does exist
            selectedTabs.removeAll { TabData in
                TabData.identifier == tabData.identifier
            }
            selectedIP.removeAll { arrayPath in
                arrayPath == indexPath
            }
            tabExists = true
        }
        
        tableState = selectedTabs.isEmpty ? .editing: .delete
        tabTableDelegate?.changeState(state: tableState)
        return tabExists
    }
    
    func deleteTabs() {
        tabHandler.deleteLocalTabs(tabs: selectedTabs) { [weak self] error in
            guard let self = self else { fatalError("Somehow self is nil...") }
            if let error {
                fatalError("Error with core data deletion \(error)")
            }
            
            self.tableViewDelegate?.removeRows(at: self.selectedIP)
            self.refresh()
        }
    }
    
    func deleteTab(at index: IndexPath) {
        let tab = tabs[index.row]
        tabHandler.deleteLocalTabs(tabs: [tab]) { [weak self] error in
            if let error = error {
                self?.tabTableDelegate.showError(error: "The Tab Could Not Be Deleted")
            }
            
            self?.tableViewDelegate?.removeRows(at: [index])
            self?.refresh()
        }
    }
    
    @objc private func iCloudUpdate(notification: NSNotification) {
        self.refresh()
    }
}
