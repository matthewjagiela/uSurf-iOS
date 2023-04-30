//
//  WebHandler.swift
//  uSurf
//
//  Created by Matthew Jagiela on 6/18/18.
//  Copyright © 2018 Matthew Jagiela. All rights reserved.
//

import UIKit

class WebHandler: NSObject {
    func determineURL(userInput: String) -> URLRequest? {
        var validDomain = false
        for domainEnding in TLDHandler.validDomains {
            if userInput.contains(domainEnding) { validDomain = true}
        }
        if validDomain {
            if userInput.contains("http://") || userInput.contains("https://") {  // This has what we need for URL protocols so we can just make the passed text a URL and then load it into the selected webView
                guard let loadURL = URL(string: userInput) else { return nil }
                return URLRequest(url: loadURL)
            } else { // We need to add http:// to the URL... (webkit should reload it with https://)
                let formattedString = "https://\(userInput)"
                print("WEB HANDLER: The formatted string is \(formattedString)")
                guard let loadURL = URL(string: formattedString) else { return nil }
                return URLRequest(url: loadURL)
            }
        } else { // This is something we are going to search with google so return the google search function....
            let googleRequest = googleSearch(userInput)
            return googleRequest
        }
    }
    
    func googleSearch(_ userInput: String) -> URLRequest? { // We need to google something so return the google request instead of loading the webpage
        print("WEB HANDLER: THE USER INPUT IS \(userInput)")
        let query = userInput.replacingOccurrences(of: " ", with: "+")
        print("WEB HANDLER: THE QUERY IS: \(query)")
        let googleSearchURL = "https://www.google.com/search?q=\(query)"
        print("WEB HANDLER: THE GOOGLE SEARCH URL IS : \(googleSearchURL)")
        guard let url = URL(string: googleSearchURL) else { return nil }
        return URLRequest(url: url)
    }
    
}
