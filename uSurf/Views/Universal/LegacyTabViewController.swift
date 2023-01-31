//
//  TabViewController.swift
//  uSurf
//
//  Created by Matthew Jagiela on 10/25/18.
//  Copyright © 2018 Matthew Jagiela. All rights reserved.
//

import UIKit
 //TODO: Change the entire tab structure. This will not matter anymore. 
class LegacyTabViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet var navigationBar: UINavigationBar!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    var searchController = UISearchController()
    var iPhoneTabArray = NSMutableArray()
    var iPadTabArray = NSMutableArray()
    let iCloud = iCloudHandler()
    let savedData = SavedDataHandler()
    var theme = ThemeHandler.shared
    var browserTag: BrowserSide = .single
    // Optional variables these do not take up memory until they are called by a method execution
    lazy var matchediPhoneTabs = [Int]() // This is going to be where the bookmarks matching with the search is
    lazy var matchediPadTabs = [Int]()
    lazy var isSearching = false
    weak var homeDelegate: HomeViewDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Load The Data:
        iPhoneTabArray = iCloud.getiPhoneTabArray()
        iPadTabArray = iCloud.getiPadTabArray()
        theming()
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        // Add an iCloud handler... This will execute whenever there is an iCloud update...
        NotificationCenter.default.addObserver(self, selector: #selector(iCloudUpdate(notification:)), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: NSUbiquitousKeyValueStore.default)
        
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.theme.regenTheme()
        theming()
        
    }
    // MARK: iCloud Update
    @objc private func iCloudUpdate(notification: NSNotification) {
        iPhoneTabArray = iCloud.getiPhoneTabArray()
        iPadTabArray = iCloud.getiPadTabArray()
        isSearching = false
        tableView.reloadData()
    }
    // MARK: Theme
    func theming() { // Lets handle the theme!
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
        
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return theme.getStatusBarColor()
    }
    // MARK: Search
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) { // There is some search happening so we need to start trying to find the timer
        print("BookarkTableViewController: We are searching")
        if let searchedItem = searchBar.text, !(searchBar.text?.isEmpty ?? false) {
            let searchArray = iPhoneTabArray as? [String] ?? ["https://uappsios.com"]
            matchediPhoneTabs = searchArray.indices.filter { // This is searching through the iPhone tab array for matches
                searchArray[$0].localizedCaseInsensitiveContains(searchedItem)
            }
            let iPadSearchArray = iPadTabArray as? [String] ?? ["https://uappsios.com"]
            matchediPadTabs = iPadSearchArray.indices.filter { // This is searching through the iPad tab arrays to find a match
                iPadSearchArray[$0].localizedCaseInsensitiveContains(searchedItem)
            }
            isSearching = true
        } else {
            isSearching = false
        }
        tableView.reloadData()
    }
    // MARK: Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "iPhone"
        } else {
            return "iPad"
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            if section == 0 {
                return matchediPhoneTabs.count
            } else {
                return matchediPadTabs.count
            }
        } else {
            if section == 0 {
                return iPhoneTabArray.count
            } else {
                return iPadTabArray.count
            }
        }
    }
    // swiftlint:disable force_unwrapping
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tabCells")
        if isSearching { // We are searching so the table has to represent this
            if indexPath.section == 0 { // iPhone while searching
                cell?.textLabel?.text = iPhoneTabArray.object(at: matchediPhoneTabs[indexPath.row]) as? String
            } else {
                cell?.textLabel?.text = iPadTabArray.object(at: matchediPadTabs[indexPath.row]) as? String
            }
            
        } else {
            if indexPath.section == 0 { // iPhone
                cell?.textLabel?.text = iPhoneTabArray.object(at: indexPath.row) as? String
            } else {
                cell?.textLabel?.text = iPadTabArray.object(at: indexPath.row) as? String
            }
        }
        cell?.backgroundColor = theme.getBarTintColor()
        cell?.textLabel?.textColor = theme.getTintColor()
        return cell!
    }
    // swiftlint:enable force_unwrapping
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Debug the browser tag is:\(browserTag)")
        if isSearching {// We are searching so we have to have the selected row the searched item
            if indexPath.section == 0 {
                // iPhone
                savedData.setLastViewedPage(lastPage: iPhoneTabArray.object(at: matchediPhoneTabs[indexPath.row]) as? String ?? "https://uappsios.com")
                switch browserTag {
                case .left: // Left
                    savedData.setLeftWebPage(URL: iPhoneTabArray.object(at: matchediPhoneTabs[indexPath.row]) as? String ?? "https://uappsios.com")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "leftWeb"), object: nil)
                    self.dismiss(animated: true, completion: nil)
                case .right:
                    savedData.setRightWebPage(URL: iPhoneTabArray.object(at: matchediPhoneTabs[indexPath.row]) as? String ?? "https://uappsios.com")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "rightWeb"), object: nil)
                    self.dismiss(animated: true, completion: nil)
                default: // Center / iPhone
                    homeDelegate?.refreshWeb(url: iPhoneTabArray.object(at: matchediPhoneTabs[indexPath.row]) as? String ?? "https://uappsios.com")
                    if UIDevice().userInterfaceIdiom == .pad {
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        self.sideMenuController?.hideMenu()
                    }
                }
            } else {
                savedData.setLastViewedPage(lastPage: iPadTabArray.object(at: matchediPadTabs[indexPath.row]) as? String ?? "https://uappsios.com")
                switch browserTag {
                case .left: // Left
                    savedData.setLeftWebPage(URL: iPadTabArray.object(at: matchediPadTabs[indexPath.row]) as? String ?? "https://uappsios.com")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "leftWeb"), object: nil)
                    self.dismiss(animated: true, completion: nil)
                case .right:
                    savedData.setRightWebPage(URL: iPadTabArray.object(at: matchediPadTabs[indexPath.row]) as? String ?? "https://uappsios.com")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "rightWeb"), object: nil)
                    self.dismiss(animated: true, completion: nil)
                default:
                    homeDelegate?.refreshWeb(url: iPhoneTabArray.object(at: matchediPadTabs[indexPath.row]) as? String ?? "https://uappsios.com")
                    if UIDevice().userInterfaceIdiom == .pad {
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        self.sideMenuController?.hideMenu()
                    }
                }
            }
            
        } else {
            if indexPath.section == 0 {
                savedData.setLastViewedPage(lastPage: iPhoneTabArray.object(at: indexPath.row) as? String ?? "https://uappsios.com")
                switch browserTag {
                case .left: // Left
                    savedData.setLeftWebPage(URL: iPhoneTabArray.object(at: indexPath.row) as? String ?? "https://uappsios.com")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "leftWeb"), object: nil)
                    self.dismiss(animated: true, completion: nil)
                case .right:
                    savedData.setRightWebPage(URL: iPhoneTabArray.object(at: indexPath.row) as? String ?? "https://uappsios.com")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "rightWeb"), object: nil)
                    self.dismiss(animated: true, completion: nil)
                default:
                    if #available(iOS 13, *) {
                        self.dismiss(animated: true, completion: nil)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshWeb"), object: nil)
                    } else { self.performSegue(withIdentifier: "goHome", sender: self) }
                }
            } else {
                savedData.setLastViewedPage(lastPage: iPadTabArray.object(at: indexPath.row) as? String ?? "https://uappsios.com")
                switch browserTag {
                case .left: // Left
                    savedData.setLeftWebPage(URL: iPadTabArray.object(at: indexPath.row) as? String ?? "https://uappsios.com")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "leftWeb"), object: nil)
                    self.dismiss(animated: true, completion: nil)
                case .right:
                    savedData.setRightWebPage(URL: iPadTabArray.object(at: indexPath.row) as? String ?? "https://uappsios.com")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "rightWeb"), object: nil)
                    self.dismiss(animated: true, completion: nil)
                default:
                    if #available(iOS 13, *) {
                        self.dismiss(animated: true, completion: nil)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshWeb"), object: nil)
                    } else { self.performSegue(withIdentifier: "goHome", sender: self) }
                }
            }
        }
        self.performSegue(withIdentifier: "goHome", sender: self)
        
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete { // We need to figure out how to delete
            if indexPath.section == 0 { // iPhone
                iPhoneTabArray.removeObject(at: indexPath.row)
                iCloud.setiPhoneTabArray(iPhoneTabArray: iPhoneTabArray)
            } else {
                iPadTabArray.removeObject(at: indexPath.row)
                iCloud.setiPadTabArray(iPadTabArray: iPadTabArray)
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } else {
            
        }
    }
    // MARK: Custom Actions
    @IBAction func goHome(_ sender: Any) {
        if #available(iOS 13, *) {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.performSegue(withIdentifier: "goHome", sender: self)
        }
    }
    
    @objc func canRotate() {}
}
