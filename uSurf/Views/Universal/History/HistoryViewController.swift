//
//  HistoryViewController.swift
//  uSurf
//
//  Created by Matthew Jagiela on 10/25/18.
//  Copyright © 2018 Matthew Jagiela. All rights reserved.
//

import UIKit

enum BrowserSide: Int {
    case single = 0
    case right = 1
    case left = 2
}

class HistoryViewController: UIViewController, UISearchBarDelegate {
    // MARK: - Outlets
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var navBar: UINavigationBar!
    
    // MARK: - Variables
    var theme = ThemeHandler.shared
    var searchController = UISearchController()
    var vm = HistoryViewModel()
    weak var homeDelegate: HomeViewDelegate?
    weak var splitDelegate: SplitViewDelegate?
    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        vm.tableDelegate = self
        theming()
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        
    }

    // MARK: - Searching
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
        navBar.barTintColor = theme.getBarTintColor() // Set the real color of the bar
        
        // SEARCH BAR:
        
        searchBar.barTintColor = theme.getSearchBarColor()
        if #available(iOS 13.0, *) {
            searchBar.searchTextField.backgroundColor = theme.getTintColor()
        }
        
        // Others:
        
        navBar.tintColor = theme.getTintColor() // Set text of the bar
        self.view.backgroundColor = theme.getBarTintColor() // Set the background text
        let textAttributes = [NSAttributedString.Key.foregroundColor: theme.getTintColor()] // Set the navigation text color
        navBar.titleTextAttributes = textAttributes // Actually update the thing
        tableView.backgroundColor = theme.getBarTintColor() // When there is no cells the view will be this color
        searchBar.barStyle = theme.getSearchStyle() // Set the theme of the search bar
        
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.backgroundColor = theme.getTextBarBackgroundColor()
        textFieldInsideSearchBar?.textColor = theme.getTextColor()
        
        self.updateTable()
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.theme.regenTheme()
        theming()
        
    }
    // MARK: - Actions
    
    @IBAction func clearHistory(_ sender: Any) {
        vm.clearAllHistory()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return theme.getStatusBarColor()
    }
    
    @objc func canRotate() {}

}

// MARK: - TableView Extensions
extension HistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.filteredHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "historyCells") else { return UITableViewCell() }
        cell.textLabel?.text = vm.url(at: indexPath.row)
        cell.textLabel?.textColor = theme.getTintColor()
        return cell
    }
}

extension HistoryViewController: UITableViewDelegate {
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

extension HistoryViewController: uAppsTableDelegate {
    func updateTable() {
        self.tableView.reloadData()
    }
}
