//
//  TLDHandler.swift
//  uSurf
//
//  Created by Matthew Jagiela on 2/23/22.
//  Copyright © 2022 Matthew Jagiela. All rights reserved.
//

import Foundation

class TLDHandler {
    static var validDomains: [String] = [".com", ".org", ".net", ".edu", ".us", ".co"]
    
    static func fetchTLD() {
        guard let tldURL = URL(string: "https://datahub.io/core/top-level-domain-names/r/0.json") else { return }
        URLSession.shared.dataTask(with: tldURL) { data, _, error in
            if let error = error {
                print("ERROR \(error)")
            }
            
            if let data = data {
                do {
                    let domainCodable = try JSONDecoder().decode([TLDDomain].self, from: data)
                    validDomains.removeAll()
                    for domain in domainCodable {
                        validDomains.append(domain.domain)
                    }

                } catch {
                    return
                }
            }
        }.resume()
    }
    
}


struct TLDDomain: Codable {
    let domain: String

    enum CodingKeys: String, CodingKey {
        case domain = "Domain"
    }
}
