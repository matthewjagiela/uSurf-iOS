//
//  BookmarkViewModel.swift
//  uSurf
//
//  Created by Matthew Jagiela on 5/22/22.
//  Copyright © 2022 Matthew Jagiela. All rights reserved.
//

import Foundation
import SwiftSoup

class BookmarkViewModel {
    
    init() {}

    func getIconURL(fromURL url: String) async throws -> String? {
        guard let websiteURL = URL(string: url) else {
            return nil
        }

        let (data, _) = try await URLSession.shared.data(from: websiteURL)

        guard let html = String(data: data, encoding: .utf8) else {
            return nil
        }

        let doc = try SwiftSoup.parse(html)

        if let faviconURL = try doc.select("link[rel='shortcut icon']").first()?.attr("href") {
            let fullFaviconURL = URL(string: faviconURL, relativeTo: websiteURL)
            return fullFaviconURL?.absoluteString
        } else {
            return nil
        }
    }

    func getFavImage(fromURL url: String) async throws -> Data? {
        guard let iconURL = try await getIconURL(fromURL: url) else {
            return nil
        }
        
        guard let imageURL = URL(string: iconURL) else {
            return nil
        }
        
        let (data, _) = try await URLSession.shared.data(from: imageURL)
        
        return data
    }
}
