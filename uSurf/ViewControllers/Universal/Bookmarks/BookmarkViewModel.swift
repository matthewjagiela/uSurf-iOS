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
    var bookmarks: [(name: String, url: String)] = [] {
        didSet {
            if let iCloudDelegate = iCloudDelegate {
                iCloudDelegate.updateUXFromiCloud()
            }
            self.updateFilteredBookmarks()
        }
    }
    
    var filteredBookmarks: [(name: String, url: String)] = [] {
        didSet {
            if let iCloudDelegate = iCloudDelegate {
                iCloudDelegate.updateUXFromiCloud()
            }
        }
    }
    
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
    
    init(iCloudDelegate: iCloudDelegate?) {
        self.iCloudDelegate = iCloudDelegate
        self.fetchBookmarks()
        //iCloud Notification Update
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
    
    func deleteBookmark(at index: Int) {
        
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