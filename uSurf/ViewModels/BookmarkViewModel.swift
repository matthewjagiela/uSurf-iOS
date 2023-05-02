//
//  BookmarkViewModel.swift
//  uSurf
//
//  Created by Matthew Jagiela on 5/22/22.
//  Copyright © 2022 Matthew Jagiela. All rights reserved.
//

import Foundation

/// A Container for custom bookmark information
struct BookmarkData {
    var name: String
    var url: String
    var identifier = UUID()
}

class BookmarkViewModel {
    @Published var bookmarks: [BookmarkData] = []
    
    let coreData = CoreDataHandler()
    
    init() {
        self.getBookmarks()
    }
    
    func getBookmarks() {
        do {
            self.bookmarks = try self.coreData.getBookmarkData()
            print(bookmarks)
        } catch {
            // TODO: Throw error toast
        }
    }
}
