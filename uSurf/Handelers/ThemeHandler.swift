//
//  ThemeHandler.swift
//  uSurf
//
//  Created by Matthew Jagiela on 7/27/18.
//  Copyright © 2018 Matthew Jagiela. All rights reserved.
//

import UIKit

class ThemeHandler: NSObject {
    let savedData = SavedDataHandler()
    var theme = ""
    override init() {
        super.init() //So we can use some initialization stuff
        theme = savedData.getTheme() //Get the theme we will be using
        
    }
    func getBarTintColor() -> UIColor { //Instead of doing this if statement for every single view controller....
        if theme == "Blue" {
            return .blue
        } else if theme == "Light" {
            return .white
        } else if theme == "Red" {
            return .red
        } else if theme == "Purple" {
            return .purple
        } else if theme == "Green" {
            return .green
        } else { //Black is the only option left and we need and else statement to make this method work for returns SOOO
            return .black
        }
    }
    func getTintColor() -> UIColor { //This is going to be the color of buttons on bars
        if theme == "Light" { //If the theme is light display black buttons
            return .black
        } else { //Everything else can have white buttons as it looks best
            return .white
        }
    }
    func getTextBarBackgroundColor() -> UIColor {
        if theme == "Dark" {
            return .gray
        } else {
            return .white
        }
    }
    func getTextColor() -> UIColor {
        if theme == "Dark" {
            return .white
        } else {
            return .black
        }
    }
    func getSearchStyle() -> UIBarStyle {
        if theme == "Dark" {
            return .black
        } else {
            return .default
        }
    }
    func getStatusBarColor() -> UIStatusBarStyle {
        if theme == "Light" {
            return .default
        } else {
            return .lightContent
        }
    }

}
