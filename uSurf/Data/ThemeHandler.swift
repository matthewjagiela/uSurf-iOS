//
//  ThemeHandler.swift
//  uSurf
//
//  Created by Matthew Jagiela on 7/27/18.
//  Copyright © 2018 Matthew Jagiela. All rights reserved.
//

import UIKit

class ThemeHandler: NSObject {
    static let shared = ThemeHandler()
    let savedData = SavedDataHandler()
    var theme: Theme = .System
    override init() {
        super.init() // So we can use some initialization stuff
        self.regenTheme()
    }
    func regenTheme() {
        theme = Theme(rawValue: savedData.getTheme()) ?? .System // Get the theme we will be using
        if #available(iOS 13, *) {
            if theme == .Dark || theme == .Light {
                theme = .System
            }
            if theme == .System {
                if UITraitCollection.current.userInterfaceStyle == .dark {
                    theme = .Dark
                } else { theme = .Light }
            }
        }

    }
    
    func setTheme(theme: Theme) {
        self.theme = theme
        if theme == .System {
            if #available(iOS 13.0, *) {
                if UITraitCollection.current.userInterfaceStyle == .dark {
                    self.theme = .Dark
                } else { self.theme = .Light }
            } else {
                self.theme = .Dark
            }
        }
    }
    
    func getBarTintColor() -> UIColor { // Instead of doing this if statement for every single view controller....
        
        switch theme {
        case .System:
            if #available(iOS 13.0, *) {
                return .systemBackground
            } else {
                return .white
            }
        case .Dark:
            return .black
        case .Light:
            return .white
        case .Blue:
            return .blue
        case .Red:
            return .red
        case .Purple:
            return .purple
        case .Green:
            return .green
        }
        
//        if theme == "Blue" {
//            return .blue
//        } else if theme == "Light" {
//            return .white
//        } else if theme == "Red" {
//            return .red
//        } else if theme == "Purple" {
//            return .purple
//        } else if theme == "Green" {
//            return .green
//        } else { // Black is the only option left and we need and else statement to make this method work for returns SOOO
//            return .black
//        }
    }
    func getTintColor() -> UIColor { // This is going to be the color of buttons on bars
        if theme == .Light { // If the theme is light display black buttons
            return .black
        } else { // Everything else can have white buttons as it looks best
            return .white
        }
    }
    func getTextBarBackgroundColor() -> UIColor {
        if theme == .Dark {
            return .gray
        } else {
            return .white
        }
    }
    func getTextColor() -> UIColor {
        if #available(iOS 13, *) {
            if UITraitCollection.current.userInterfaceStyle == .dark && theme == .Dark {
                return .white
            } else { return .black }
        } else {
            if theme == .Dark {
                return .white
            } else {
                return .black
            }
        }
    }
    
    // MARK: - Status Bar
    func getSearchBarColor() -> UIColor {
        if theme == .Dark {
            return .black
        } else if theme == .Light {
            return .lightGray
        } else { return self.getBarTintColor() }
    }
    
    func getSearchStyle() -> UIBarStyle {
        if theme == .Dark {
            return .black
        } else {
            return .default
        }
    }
    func getStatusBarColor() -> UIStatusBarStyle {
        if theme == .Light {
            return .default
        } else {
            return .lightContent
        }
    }

}
