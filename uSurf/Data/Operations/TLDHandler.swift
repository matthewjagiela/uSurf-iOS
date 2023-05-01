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
    
    static func fetchTLD(completion: @escaping (_ success: Bool) -> Void) {
        guard let tldURL = URL(string: "https://datahub.io/core/top-level-domain-names/r/0.json") else { return }
        URLSession.shared.dataTask(with: tldURL) { data, _, error in
            if let error = error {
                print("ERROR \(error)")
                fetchLocalTLD { success in
                    completion(success)
                }
            }
            
            if let data = data {
                do {
                    let domainCodable = try JSONDecoder().decode([TLDDomain].self, from: data)
                    validDomains.removeAll()
                    for domain in domainCodable {
                        validDomains.append(domain.domain)
                    }
                    completion(true)

                } catch {
                    fetchLocalTLD { success in
                        completion(success)
                    }
                    return
                }
            }
        }.resume()
    }
    
    static func fetchLocalTLD(success: @escaping(_ success: Bool) -> Void) {
        do {
            if let bundlePath = Bundle.main.path(forResource: "TLD", ofType: "json"), let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                let domainCodable = try JSONDecoder().decode([TLDDomain].self, from: jsonData)
                validDomains.removeAll()
                for domain in domainCodable {
                    validDomains.append(domain.domain)
                }
                success(true)
            } else {
                success(false)
                return
            }
        } catch {
            success(false)
        }
    }
    
}

struct TLDDomain: Codable {
    let domain: String

    enum CodingKeys: String, CodingKey {
        case domain = "Domain"
    }
}
