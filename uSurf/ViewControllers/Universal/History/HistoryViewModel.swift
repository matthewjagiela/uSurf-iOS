//
//  HistoryViewModel.swift
//  uSurf
//
//  Created by Matthew Jagiela on 6/19/22.
//  Copyright © 2022 Matthew Jagiela. All rights reserved.
//

import Foundation

class HistoryViewModel {
    weak var iCloudDelegate: iCloudDelegate?
    weak var tableDelegate: uAppsTableDelegate?
    var browserSide: BrowserSide?
    
    init(iCloudDelegate: iCloudDelegate? = nil, browserSide: BrowserSide? = nil) {
        self.iCloudDelegate = iCloudDelegate
        self.browserSide = browserSide
    }
}
