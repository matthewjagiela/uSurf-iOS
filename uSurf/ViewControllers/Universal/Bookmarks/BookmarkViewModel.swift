//
//  BookmarkViewModel.swift
//  uSurf
//
//  Created by Matthew Jagiela on 5/22/22.
//  Copyright © 2022 Matthew Jagiela. All rights reserved.
//

import Foundation

class BookmarkViewModel {
    weak var iCloudDelegate: iCloudDelegate?
    var iCloud = iCloudHandler()
    var localStorage = SavedDataHandler()
    var browserSide: BrowserSide?
    var bookmarks: [(name: String, url: String)] = [] {
        didSet {
            if let iCloudDelegate = iCloudDelegate {
                iCloudDelegate.updateUXFromiCloud()
            }
            self.updateFilteredBookmarks()
        }
    }
    
    var filteredBookmarks: [(name: String, url: String)] = []
    
    var searchTerm: String = "" {
        didSet {
            if searchTerm.isEmpty {
                filteredBookmarks = bookmarks
            } else {
                filteredBookmarks = bookmarks.filter {
                    $0.name.lowercased().contains(searchTerm.lowercased()) || $0.url.lowercased().contains(searchTerm.lowercased())
                }
            }
            print(filteredBookmarks)
        }
    }
    
    init(iCloudDelegate: iCloudDelegate?, browserSide: BrowserSide? = nil) {
        self.iCloudDelegate = iCloudDelegate
        self.fetchBookmarks()
        self.browserSide = browserSide
        NotificationCenter.default.addObserver(self, selector: #selector(iCloudUpdate(notification:)), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: NSUbiquitousKeyValueStore.default)
    }
    
    @objc private func iCloudUpdate(notification: NSNotification) {
        self.fetchBookmarks()
    }
    
    func fetchBookmarks() {
        self.bookmarks = iCloud.getBookmarkTupleArray()
    }
    
    func name(at index: Int) -> String {
        return filteredBookmarks[index].name
    }
    
    func url(at index: Int) -> String {
        return filteredBookmarks[index].url
    }
    
    func deleteBookmark(filteredIndex: Int) {
        let data = filteredBookmarks[filteredIndex]
        let nameArray = iCloud.getBookmarkNameArray()
        let urlArray = iCloud.getBookmarkArray()
        let nameIndex = nameArray.indexOfObjectIdentical(to: data.name)
        let urlIndex = urlArray.indexOfObjectIdentical(to: data.url)
        nameArray.removeObject(at: nameIndex)
        urlArray.removeObject(at: urlIndex)
        iCloud.setBookmarkNameArray(bookmarkNameArray: nameArray)
        iCloud.setBookmarkNameArray(bookmarkArray: urlArray)
        fetchBookmarks()
    }
    
    func updateFilteredBookmarks() {
        if searchTerm.isEmpty {
            filteredBookmarks = bookmarks
        } else {
            filteredBookmarks = bookmarks.filter {
                $0.name.lowercased().contains(searchTerm.lowercased()) || $0.url.lowercased().contains(searchTerm.lowercased())
            }
        }
    }
}
