//
//  HistoryViewController.swift
//  uSurf
//
//  Created by Matthew Jagiela on 10/25/18.
//  Copyright © 2018 Matthew Jagiela. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    // MARK: - Outlets
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var navBar: UINavigationBar!
    // MARK: - Variables
    let savedData = SavedDataHandler()
    var theme = ThemeHandler()
    var historyArray = NSMutableArray()
    var searchController = UISearchController()
    lazy var matchedHistory = [Int]()
    lazy var isSearching = false
    var browserTag = 0
    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        historyArray = savedData.getHistoryArray()
        theming()
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        print("DEBUG: History View Controller TAG \(browserTag)")
        
    }
    // MARK: - Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching { //Return the matched count
            return matchedHistory.count
        } else {
            return historyArray.count
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { //Depending on if filters are applied or not set the URL
        if isSearching { //the selection is from the searched group...
            let searchedIndex = matchedHistory[indexPath.row] //The index of where it is in the main array.
            switch browserTag {
            case 1: //Left
                savedData.setLeftWebPage(URL: historyArray[searchedIndex] as? String ?? "https://uappsios.com")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "leftWeb"), object: nil)
                self.dismiss(animated: true, completion: nil)
            case 2:
                savedData.setRightWebPage(URL: historyArray[searchedIndex] as? String ?? "https://uappsios.com")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "rightWeb"), object: nil)
                self.dismiss(animated: true, completion: nil)
            default:
                savedData.setLastViewedPage(lastPage: historyArray[searchedIndex] as? String ?? "https://uappsios.com")
                if #available(iOS 13, *) {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshWeb"), object: nil)
                    self.dismiss(animated: true, completion: nil)
                } else { self.performSegue(withIdentifier: "goHome", sender: self) }
            }
            //savedData.setLastViewedPage(lastPage: historyArray[searchedIndex] as! String)
        } else { //This is just throughout the main array
            switch browserTag {
            case 1: //Left
                savedData.setLeftWebPage(URL: historyArray[indexPath.row] as? String ?? "https://uappsios.com")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "leftWeb"), object: nil)
                self.dismiss(animated: true, completion: nil)
            case 2:
                savedData.setRightWebPage(URL: historyArray[indexPath.row] as? String ?? "https://uappsios.com")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "rightWeb"), object: nil)
                self.dismiss(animated: true, completion: nil)
            default:
                savedData.setLastViewedPage(lastPage: historyArray[indexPath.row] as? String ?? "https://uappsios.com")
                if #available(iOS 13, *) {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshWeb"), object: nil)
                    self.dismiss(animated: true, completion: nil)
                } else { self.performSegue(withIdentifier: "goHome", sender: self) }
            }
        }
    }
    //swiftlint:disable force_unwrapping
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCells")
        if isSearching { //Display only the search results
            cell?.textLabel?.text = (historyArray.object(at: matchedHistory[indexPath.row]) as? String ?? "uApps iOS")
        } else { //Display all the results
            cell?.textLabel?.text = (historyArray.object(at: indexPath.row) as? String ?? "uApps iOS")
        }
        cell?.backgroundColor = theme.getBarTintColor()
        cell?.textLabel?.textColor = theme.getTintColor()
        return cell!
        
    }
    //swiftlint:enable force_unwrapping

    // MARK: - Searching
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("History: We are searching")
        //Do the actual search...
        if let searchedItem = searchBar.text, !(searchBar.text?.isEmpty ?? true) {
            let searchArray = historyArray as? [String] ?? ["https://uappsios.com"]
            matchedHistory = searchArray.indices.filter {
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
        searchController.searchResultsUpdater = self as? UISearchResultsUpdating //search results are handled in this class
        searchController.hidesNavigationBarDuringPresentation = false //Make sure the nav bar stays
        searchController.dimsBackgroundDuringPresentation = true //Not sure
        searchController.searchBar.delegate = self // we want to use delegate methods here
        tableView.tableFooterView = UIView(frame: .zero) //Make sure that the entire thing is in frame
        tableView.rowHeight = 71 //Row height for the text
        navBar.barTintColor = theme.getBarTintColor() //Set the real color of the bar
        
        //SEARCH BAR:
        
        searchBar.barTintColor = theme.getSearchBarColor()
        searchBar.searchTextField.backgroundColor = theme.getTintColor()
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.backgroundColor = theme.getTextBarBackgroundColor()
        textFieldInsideSearchBar?.textColor = theme.getTextColor()
        
        //Others:
        
        navBar.tintColor = theme.getTintColor() //Set text of the bar
        self.view.backgroundColor = theme.getBarTintColor() //Set the background text
        let textAttributes = [NSAttributedString.Key.foregroundColor: theme.getTintColor()] //Set the navigation text color
        navBar.titleTextAttributes = textAttributes //Actually update the thing
        tableView.backgroundColor = theme.getBarTintColor() //When there is no cells the view will be this color
        searchBar.barStyle = theme.getSearchStyle() //Set the theme of the search bar
        
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
           super.traitCollectionDidChange(previousTraitCollection)
           theme = ThemeHandler()
           theming()
           
       }
    // MARK: - Actions
    @IBAction func goHome(_ sender: Any) {
        if #available(iOS 13, *) {
            dismiss(animated: true, completion: nil)
        } else {
            self.performSegue(withIdentifier: "goHome", sender: self)
        }
    }
    @IBAction func clearHistory(_ sender: Any) {
        historyArray.removeAllObjects()
        savedData.saveHistoryArray(historyArray: historyArray)
        self.tableView.reloadData()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return theme.getStatusBarColor()
    }
    @objc func canRotate() {}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
