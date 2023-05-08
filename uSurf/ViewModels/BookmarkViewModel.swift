//
//  BookmarkViewModel.swift
//  uSurf
//
//  Created by Matthew Jagiela on 5/22/22.
//  Copyright © 2022 Matthew Jagiela. All rights reserved.
//

import Foundation

/// A Container for custom bookmark information
struct BookmarkData: Hashable {
    var name: String
    var url: String
    var identifier = UUID()
}

protocol CoreDataService {
    func getData() throws -> Any
}

class BookmarkViewModel: ObservableObject {
    @Published var bookmarks: [BookmarkData] = []
    @Published var filteredBookmarks: [BookmarkData] = []
    
    var coreDataService: CoreDataService
    
    let coreData = CoreDataHandler()
    
    init(coreDataService: CoreDataService) {
        self.coreDataService = coreDataService
        self.getBookmarks()
    }
    
    func getBookmarks() {
        do {
            self.bookmarks = try self.coreDataService.getData() as? [BookmarkData] ?? []
            self.filteredBookmarks = self.bookmarks
        } catch {
            // TODO: Throw error toast here
        }
    }
    
    func filterBookmarks(searchText: String) {
        if searchText.isEmpty {
            filteredBookmarks = self.bookmarks
            return
        }
        
        self.filteredBookmarks = self.bookmarks.filter({ bookmarkData in
            bookmarkData.name.lowercased().contains(searchText.lowercased()) || bookmarkData.url.lowercased().contains(searchText.lowercased())
        })

    }
    
    func getFavIconURL(webURL: String) -> URL? {
        let favicon = FavIconOperation()
        let faviconURL = favicon.getIconURL(domain: webURL)
        return faviconURL
    }
    
    func deleteBookmark(at index: Int) {
        let deletionBookmark = filteredBookmarks[index]
        do {
            try coreData.deleteBookmark(from: deletionBookmark)
            filteredBookmarks.remove(at: index)
            bookmarks.removeAll { bookmarkData in
                deletionBookmark.identifier == bookmarkData.identifier
            }
        } catch {
            // TODO: Throw Toast Here
        }
    }
}

class BookmarkDataFetcher: CoreDataService {
    let coreData = CoreDataHandler()
    func getData() throws -> Any {
        return try coreData.getBookmarkData()
    }
}

class MockBookmarkDataFetcher: CoreDataService {
    func getData() throws -> Any {
        let bookmarkData = [BookmarkData(name: "Apple", url: "http://apple.com"), BookmarkData(name: "uApps", url: "https://uappsios.com"), BookmarkData(name: "Google", url: "https://google.com"), BookmarkData(name: "Youtube", url: "http://youtube.com")]
        return bookmarkData
    }
}
