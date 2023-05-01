//
//  BookmarkTableViewController.swift
//  uSurf
//
//  Created by Matthew Jagiela on 10/16/18.
//  Copyright © 2018 Matthew Jagiela. All rights reserved.
//

import UIKit

protocol uAppsTableDelegate: AnyObject {
    func updateTable()
    func removeRows(at indexPath: [IndexPath])
}

class BookmarkTableViewController: UIViewController {

    var theme = ThemeHandler.shared
    // Optional variables these do not take up memory until they are called by a method execution
    
    weak var homeDelegate: HomeViewDelegate?
    weak var splitDelegate: SplitViewDelegate?
    
    var vm: BookmarkViewModel = BookmarkViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return theme.getStatusBarColor()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.theme.regenTheme()
        
    }
    
    @objc func canRotate() {}
}
