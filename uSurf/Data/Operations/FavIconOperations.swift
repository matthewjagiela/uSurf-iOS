//
//  FavIconOperations.swift
//  uSurf
//
//  Created by Matthew Jagiela on 5/1/23.
//  Copyright © 2023 Matthew Jagiela. All rights reserved.
//

import Foundation

enum FavIconSize: Int, CaseIterable {
    case s = 16
    case m = 32
    case l = 64
    case xl = 128
    case xxl = 256
    case xxxl = 512
}

class FavIconOperation {
    func getIconURL(domain: String, size: FavIconSize = .m) -> URL? {
        return URL(string: "https://www.google.com/s2/favicons?sz=\(size.rawValue)&domain=\(domain)")
    }
    
    func getFavIconPNG(from url: URL) async throws -> Data? {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        } catch {
            print("Error getting favicon image: \(error.localizedDescription)")
            return nil
        }
    }
}
