//
//  BookmarkTableViewController.swift
//  uSurf
//
//  Created by Matthew Jagiela on 10/16/18.
//  Copyright © 2018 Matthew Jagiela. All rights reserved.
//

import UIKit

class BookmarkTableViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet var navigationBar: UINavigationBar!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    
    var searchController = UISearchController()

    var theme = ThemeHandler()
    // Optional variables these do not take up memory until they are called by a method execution
    lazy var matchedBookmarks = [Int]() // This is going to be where the bookmarks matching with the search is
    lazy var isSearching = false
    
    weak var homeDelegate: HomeViewDelegate?
    weak var splitDelegate: SplitViewDelegate?
    
    var vm: BookmarkViewModel = BookmarkViewModel(iCloudDelegate: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vm.iCloudDelegate = self
        theming()
        // Lets handle some data type stuff:
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        vm.searchTerm = searchText
    }
    
    // MARK: - Theme
    
    private func theming() {
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self as? UISearchResultsUpdating // search results are handled in this class
        searchController.hidesNavigationBarDuringPresentation = false // Make sure the nav bar stays
        searchController.dimsBackgroundDuringPresentation = true // Not sure
        searchController.searchBar.delegate = self // we want to use delegate methods here
        tableView.tableFooterView = UIView(frame: .zero) // Make sure that the entire thing is in frame
        tableView.rowHeight = 71 // Row height for the text
        navigationBar.barTintColor = theme.getBarTintColor() // Set the real color of the bar
        
        // SEARCH BAR:
        
        searchBar.barTintColor = theme.getSearchBarColor()
        if #available(iOS 13.0, *) {
            searchBar.searchTextField.backgroundColor = theme.getTintColor()
        }
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.backgroundColor = theme.getTextBarBackgroundColor()
        textFieldInsideSearchBar?.textColor = theme.getTextColor()
        
        // Others:
        
        navigationBar.tintColor = theme.getTintColor() // Set text of the bar
        self.view.backgroundColor = theme.getBarTintColor() // Set the background text
        let textAttributes = [NSAttributedString.Key.foregroundColor: theme.getTintColor()] // Set the navigation text color
        navigationBar.titleTextAttributes = textAttributes // Actually update the thing
        tableView.backgroundColor = theme.getBarTintColor() // When there is no cells the view will be this color
        searchBar.barStyle = theme.getSearchStyle() // Set the theme of the search bar
        
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return theme.getStatusBarColor()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        theme = ThemeHandler()
        theming()
        
    }
    // MARK: - Custom Actions
    @IBAction func goHome(_ sender: Any) {
        if let iPhoneControl = sideMenuController {
            iPhoneControl.hideMenu()
        } else {
            self.dismiss(animated: true)
        }
    }
    
    @objc func canRotate() {}
}

extension BookmarkTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        vm.filteredBookmarks.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var bookmarkName = ""
        var bookmarkURL = ""
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookmarkCell")

        bookmarkName = vm.name(at: indexPath.row)
        bookmarkURL = vm.url(at: indexPath.row)
        guard let cell = cell else {
            return UITableViewCell()
        }
        
        cell.textLabel?.text = bookmarkName
        cell.detailTextLabel?.text = bookmarkURL
        cell.backgroundColor = theme.getBarTintColor()
        cell.textLabel?.textColor = theme.getTintColor()
        cell.detailTextLabel?.textColor = theme.getTintColor()
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
}

extension BookmarkTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let homeDelegate = homeDelegate {
            homeDelegate.refreshWeb(url: vm.url(at: indexPath.row))
            if let iPhoneController = sideMenuController {
                iPhoneController.hideMenu()
            } else {
                self.dismiss(animated: true)
            }
        } else if let splitDelegate = splitDelegate, let side = vm.browserSide {
            splitDelegate.refresh(url: vm.url(at: indexPath.row), side: side)
            self.dismiss(animated: true)
        }
    }
}

extension BookmarkTableViewController: iCloudDelegate {
    func updateUXFromiCloud() {
        isSearching = false
        tableView.reloadData()
    }
}
