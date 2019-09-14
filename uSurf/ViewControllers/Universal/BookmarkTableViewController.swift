//
//  BookmarkTableViewController.swift
//  uSurf
//
//  Created by Matthew Jagiela on 10/16/18.
//  Copyright © 2018 Matthew Jagiela. All rights reserved.
//

import UIKit

class BookmarkTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet var navigationBar: UINavigationBar!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    
    var searchController = UISearchController()
    var bookmarkArray = NSMutableArray()
    var bookmarkNameArray = NSMutableArray()
    let iCloud = iCloudHandler()
    let savedData = SavedDataHandler()
    let theme = ThemeHandler()
    //Optional variables these do not take up memory until they are called by a method execution
    lazy var matchedBookmarks = [Int]() //This is going to be where the bookmarks matching with the search is
    lazy var isSearching = false
    var browserTag = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        bookmarkArray = iCloud.getBookmarkArray()
        bookmarkNameArray = iCloud.getBookmarkNameArray()
        theming()
        //Lets handle some data type stuff:
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(iCloudUpdate(notification:)), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: NSUbiquitousKeyValueStore.default)
    }

    @objc private func iCloudUpdate(notification: NSNotification) { //This will be called when something within iCloud has changed...
        bookmarkArray = iCloud.getBookmarkArray()
        bookmarkNameArray = iCloud.getBookmarkNameArray()
        isSearching = false
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) { //There is some search happening so we need to start trying to find the timer
        print("BookarkTableViewController: We are searching")
        if let searchedItem = searchBar.text, searchBar.text != ""{
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

    // MARK: - Table view data source

    private func theming() {
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self as? UISearchResultsUpdating //search results are handled in this class
        searchController.hidesNavigationBarDuringPresentation = false //Make sure the nav bar stays
        searchController.dimsBackgroundDuringPresentation = true //Not sure
        searchController.searchBar.delegate = self // we want to use delegate methods here
        tableView.tableFooterView = UIView(frame: .zero) //Make sure that the entire thing is in frame
        tableView.rowHeight = 71 //Row height for the text
        navigationBar.barTintColor = theme.getBarTintColor() //Set the real color of the bar
        navigationBar.tintColor = theme.getTintColor() //Set text of the bar
        self.view.backgroundColor = theme.getBarTintColor() //Set the background text
        let textAttributes = [NSAttributedString.Key.foregroundColor: theme.getTintColor()] //Set the navigation text color
        navigationBar.titleTextAttributes = textAttributes //Actually update the thing
        tableView.backgroundColor = theme.getBarTintColor() //When there is no cells the view will be this color
        searchBar.barStyle = theme.getSearchStyle() //Set the theme of the search bar
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField //extract the text
        
        textFieldInsideSearchBar?.textColor = theme.getTintColor() //Change the color to white
        
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return theme.getStatusBarColor()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Bookmark Table View: Returning \(bookmarkNameArray.count) items")
        if isSearching {
           return matchedBookmarks.count
        } else {
           return bookmarkNameArray.count
        }
       
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isSearching { //This is a selection from a search
            print(matchedBookmarks)
            let searchedIndex = matchedBookmarks[indexPath.row] //This correlates to the index of the address in our main table
            savedData.setLastViewedPage(lastPage: bookmarkArray[searchedIndex] as? String ?? "https://uappsios.com") //Set the url to load from the main bookmark table based on the searched stored
            switch browserTag {
            case 1: //Left
                savedData.setLeftWebPage(URL: bookmarkArray[searchedIndex] as? String ?? "https://uappsios.com")
                self.performSegue(withIdentifier: "goSplit", sender: self)
            case 2:
                savedData.setRightWebPage(URL: bookmarkArray[searchedIndex] as? String ?? "https://uappsios.com")
                self.performSegue(withIdentifier: "goSplit", sender: self)
            default:
                savedData.setLastViewedPage(lastPage: bookmarkArray[searchedIndex] as? String ?? "https://uappsios.com")
                self.performSegue(withIdentifier: "goHome", sender: self) //Go home and load the page
            }
            
        } else {
            savedData.setLastViewedPage(lastPage: bookmarkArray[indexPath.row] as? String ?? "https://uappsios.com") //There is no search... We can just load the page from the selected index
            switch browserTag {
            case 1: //Left
                savedData.setLeftWebPage(URL: bookmarkArray[indexPath.row] as? String ?? "https://uappsios.com")
                self.performSegue(withIdentifier: "goSplit", sender: self)
            case 2:
                savedData.setRightWebPage(URL: bookmarkArray[indexPath.row] as? String ?? "https://uappsios.com")
                self.performSegue(withIdentifier: "goSplit", sender: self)
            default:
                savedData.setLastViewedPage(lastPage: bookmarkArray[indexPath.row] as? String ?? "https://uappsios.com")
                self.performSegue(withIdentifier: "goHome", sender: self) //Go home and load
            
            }
        }
        //self.performSegue(withIdentifier: "goHome", sender: self) //Return to the browser with the new page loaded.
    }
    //swiftlint:disable force_unwrapping
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var bookmarkName = ""
        var bookmarkURL = ""
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookmarkCell")
        if isSearching { //The user is currently searching for a bookmark so we need to display the filtered results
            bookmarkName = (bookmarkNameArray.object(at: matchedBookmarks[indexPath.row]) as? String ?? "https://uappsios.com")
            bookmarkURL = (bookmarkArray.object(at: matchedBookmarks[indexPath.row]) as? String ?? "uApps")
        } else { //Display the entire list
            bookmarkName = (bookmarkNameArray.object(at: indexPath.row) as? String ?? "uApps")
            bookmarkURL = (bookmarkArray.object(at: indexPath.row) as? String ?? "https://uappsios.com")
        }
        cell?.textLabel?.text = bookmarkName
        cell?.detailTextLabel?.text = bookmarkURL
        cell?.backgroundColor = theme.getBarTintColor()
        cell?.textLabel?.textColor = theme.getTintColor()
        cell?.detailTextLabel?.textColor = theme.getTintColor()
        return cell!
    }
    //swiftlint:enable force_unwrapping
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */
    
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
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
    @objc func canRotate() {}

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
