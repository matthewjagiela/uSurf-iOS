//
//  SettingsViewModel.swift
//  uSurf
//
//  Created by Matthew Jagiela on 6/20/22.
//  Copyright © 2022 Matthew Jagiela. All rights reserved.
//

import Foundation
import uAppsLibrary

class SettingsViewModel {
    weak var homeDelegate: HomeViewDelegate?
    weak var settingsDelegate: SettingsDelegate?
    let savedData = SavedDataHandler()
    let info = AppInformation()
    var internetInformation: InternetInformation?
    
    init(homeViewDelegate: HomeViewDelegate? = nil, settingsDelegate: SettingsDelegate?) {
        self.homeDelegate = homeViewDelegate
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
}
