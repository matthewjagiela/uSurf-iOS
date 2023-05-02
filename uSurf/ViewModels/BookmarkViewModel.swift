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
    
    var coreDataService: CoreDataService
    
    let coreData = CoreDataHandler()
    
    init(coreDataService: CoreDataService) {
        self.coreDataService = coreDataService
        self.getBookmarks()
    }
    
    func getBookmarks() {
        do {
            self.bookmarks = try self.coreDataService.getData() as? [BookmarkData] ?? []
        } catch {
            // TODO: Throw error toast here
        }
    }
    
    func getFavIconURL(webURL: String) -> URL {
        let favicon = FavIconOperation()
        let faviconURL = favicon.getIconURL(domain: webURL)
        return faviconURL!
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
        let bookmarkData = [BookmarkData(name: "Apple", url: "http://apple.com"), BookmarkData(name: "uApps", url: "https://uappsios.com")]
        return bookmarkData
    }
}
