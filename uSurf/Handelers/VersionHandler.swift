//
//  VersionHandler.swift
//  uSurf
//
//  Created by Matthew Jagiela on 1/28/19.
//  Copyright © 2019 Matthew Jagiela. All rights reserved.
//

import UIKit

class VersionHandler: NSObject {
    
    func getAppVersion() -> String {
        return "Currently Running: 6.1"
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
