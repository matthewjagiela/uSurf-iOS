//
//  VersionHandler.swift
//  uSurf
//
//  Created by Matthew Jagiela on 1/28/19.
//  Copyright © 2019 Matthew Jagiela. All rights reserved.
//

import UIKit

class VersionHandler: NSObject {
    var internetInfo: InternetInformation?
    override init() {
        super.init()
        if let jsonURL = URL(string: "https://raw.githubusercontent.com/matthewjagiela/uApps-JSON/master/uAppsInfo.json") {
            URLSession.shared.dataTask(with: jsonURL) { data, _, error in
                if let fetchedData = data {
                    let decoder = JSONDecoder()
                    do {
                        self.internetInfo = try decoder.decode(InternetInformation.self, from: fetchedData)
            
                    } catch {
                        print("An Error Has Occured \(error)")
                    }
                }
            }.resume()
        }
        
    }
    
    func getAppVersion() -> String {
        return "Currently Running: 6.2"
    }
    func getUpdateInformation() -> String {
        if let path = Bundle.main.path(forResource: "Changes", ofType: "txt") {
            
            if let contents = try? String(contentsOfFile: path) {
                
                return contents
                
            } else {
                
                print("Error! - This file doesn't contain any text.")
            }
            
        } else {
            
            print("Error! - This file doesn't exist.")
        }
        
        return ""
    }

}
open class InternetInformation: NSObject, Decodable {
    public var uSurfVersion: String?
    public var uAppsNews: String?
    enum CodingKeys: String, CodingKey {
        case uTimeVersion = "uSurf_Version"
        case uAppsNews =  "uApps_News"
    }
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        uSurfVersion = try? container.decode(String.self, forKey: .uTimeVersion)
        uAppsNews = try? container.decode(String.self, forKey: .uAppsNews)
    }
}
