//
//  BookmarkTableViewController.swift
//  uSurf
//
//  Created by Matthew Jagiela on 10/16/18.
//  Copyright © 2018 Matthew Jagiela. All rights reserved.
//

import UIKit

protocol iCloudDelegate: AnyObject { //TODO: Move this
    func updateUXFromiCloud()
}

class BookmarkTableViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet var navigationBar: UINavigationBar!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    
    var searchController = UISearchController()
    var bookmarkArray = NSMutableArray()
    var bookmarkNameArray = NSMutableArray()
    let iCloud = iCloudHandler()
    let savedData = SavedDataHandler()
    var theme = ThemeHandler()
    // Optional variables these do not take up memory until they are called by a method execution
    lazy var matchedBookmarks = [Int]() // This is going to be where the bookmarks matching with the search is
    lazy var isSearching = false
    
    weak var homeDelegate: HomeViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //TODO: Change this to fetching from vm OR just have whatever is calling it go to the VM for the data source...
        bookmarkArray = iCloud.getBookmarkArray()
        bookmarkNameArray = iCloud.getBookmarkNameArray()
        theming()
        // Lets handle some data type stuff:
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
    }
    
    //TODO: Change to safer approach
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) { // There is some search happening so we need to start trying to find the timer
        print("BookarkTableViewController: We are searching")
        if let searchedItem = searchBar.text, !(searchBar.text?.isEmpty ?? true) {
            let searchArray = bookmarkNameArray as? [String] ?? ["uApps"]
            matchedBookmarks = searchArray.indices.filter {
                searchArray[$0].localizedCaseInsensitiveContains(searchedItem)
            }
            isSearching = true
        } else {
            isSearching = false
        }
        tableView.reloadData()
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
    }
    
    @objc func canRotate() {}
}

extension BookmarkTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Bookmark Table View: Returning \(bookmarkNameArray.count) items")
        if isSearching {
            return matchedBookmarks.count
        } else {
            return bookmarkNameArray.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var bookmarkName = ""
        var bookmarkURL = ""
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookmarkCell")
        if isSearching { // The user is currently searching for a bookmark so we need to display the filtered results
            bookmarkName = (bookmarkNameArray.object(at: matchedBookmarks[indexPath.row]) as? String ?? "https://uappsios.com")
            bookmarkURL = (bookmarkArray.object(at: matchedBookmarks[indexPath.row]) as? String ?? "uApps")
        } else { // Display the entire list
            bookmarkName = (bookmarkNameArray.object(at: indexPath.row) as? String ?? "uApps")
            bookmarkURL = (bookmarkArray.object(at: indexPath.row) as? String ?? "https://uappsios.com")
        }
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
            // Delete the row from the data source
            bookmarkArray.removeObject(at: indexPath.row)
            bookmarkNameArray.removeObject(at: indexPath.row)
            iCloud.setBookmarkArray(bookmarkArray: bookmarkArray)
            iCloud.setBookmarkNameArray(bookmarkNameArray: bookmarkNameArray)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
}

extension BookmarkTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { //TODO: This will change with VM implementation
        
        if isSearching { // This is a selection from a search
//            print(matchedBookmarks)
//            let searchedIndex = matchedBookmarks[indexPath.row] // This correlates to the index of the address in our main table
//            savedData.setLastViewedPage(lastPage: bookmarkArray[searchedIndex] as? String ?? "https://uappsios.com") // Set the url to load from the main bookmark table based on the searched stored
//            switch browserTag {
//            case .left: // Left
//                savedData.setLeftWebPage(URL: bookmarkArray[searchedIndex] as? String ?? "https://uappsios.com")
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "leftWeb"), object: nil)
//                self.dismiss(animated: true, completion: nil)
//            case .right:
//                savedData.setRightWebPage(URL: bookmarkArray[searchedIndex] as? String ?? "https://uappsios.com")
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "rightWeb"), object: nil)
//                self.dismiss(animated: true, completion: nil)
//            default:
//                savedData.setLastViewedPage(lastPage: bookmarkArray[searchedIndex] as? String ?? "https://uappsios.com")
//                homeDelegate?.refreshWeb(url: bookmarkArray[searchedIndex] as? String ?? "https://uappsios.com")
//                if UIDevice().userInterfaceIdiom == .pad {
//                    self.dismiss(animated: true, completion: nil)
//                } else {
//                    self.sideMenuController?.hideMenu()
//                }
//            }
            
        } else {
//            savedData.setLastViewedPage(lastPage: bookmarkArray[indexPath.row] as? String ?? "https://uappsios.com") // There is no search... We can just load the page from the selected index
//            switch browserTag {
//            case .left: // Left
//                savedData.setLeftWebPage(URL: bookmarkArray[indexPath.row] as? String ?? "https://uappsios.com")
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "leftWeb"), object: nil)
//                self.dismiss(animated: true, completion: nil)
//            case .right:
//                savedData.setRightWebPage(URL: bookmarkArray[indexPath.row] as? String ?? "https://uappsios.com")
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "rightWeb"), object: nil)
//                self.dismiss(animated: true, completion: nil)
//            default:
//                savedData.setLastViewedPage(lastPage: bookmarkArray[indexPath.row] as? String ?? "https://uappsios.com")
//                homeDelegate?.refreshWeb(url: bookmarkArray[indexPath.row] as? String ?? "https://uappsios.com")
//                if UIDevice().userInterfaceIdiom == .pad {
//                    self.dismiss(animated: true, completion: nil)
//                } else {
//                    self.sideMenuController?.hideMenu()
//                }
//                
//            }
        }
    }
}

extension BookmarkTableViewController: iCloudDelegate {
    func updateUXFromiCloud() {
        bookmarkArray = iCloud.getBookmarkArray()
        bookmarkNameArray = iCloud.getBookmarkNameArray()
        isSearching = false
        tableView.reloadData()
    }
}
