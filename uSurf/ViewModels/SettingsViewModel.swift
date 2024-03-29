//
//  SettingsViewModel.swift
//  uSurf
//
//  Created by Matthew Jagiela on 6/20/22.
//  Copyright © 2022 Matthew Jagiela. All rights reserved.
//

import Foundation
import uAppsLibrary

enum Theme: String, CaseIterable {
    case System
    case Dark
    case Light
    case Blue
    case Red
    case Purple
    case Green
}

class SettingsViewModel {
    weak var homeViewDelegate: HomeViewDelegate?
    weak var settingsDelegate: SettingsDelegate?
    let savedData = SavedDataHandler()
    let info = AppInformation()
    let theme = ThemeHandler.shared
    var internetInformation: InternetInformation?
    
    init(settingsDelegate: SettingsDelegate?) {
        self.settingsDelegate = settingsDelegate
    }
    
    func getInternetLabels() {
        let info = InternetLabelsManager()
        info.legacyFetchLabels { [weak self] information in
            self?.settingsDelegate?.reloadInternetLabels(information: information)
        }
    }
    
    func getCurrentVersion() -> String {
        return info.getAppVersion()
    }
    
    func getChanges() -> String {
        return info.getChanges()
    }
    
    func getShareURL() -> URL? {
        return URL(string: "https://itunes.apple.com/us/app/utime-universal/id1125889944?ls=1&mt=8")
    }
    
    func getShareString() -> String {
        return "I am using uSurf as my new iOS Web Browser! Check it out!"
    }
    
    func setTheme(theme: Theme) {
        let themeRaw = theme.rawValue
        savedData.setTheme(theme: themeRaw)
        self.theme.setTheme(theme: theme)
        settingsDelegate?.refreshTheme()
        homeViewDelegate?.refreshTheme()
    }
    
    func selectableThemes() -> [Theme] {
        let possibleThemes = Theme.allCases
        return Array(possibleThemes[3..<possibleThemes.count])
    }
}
