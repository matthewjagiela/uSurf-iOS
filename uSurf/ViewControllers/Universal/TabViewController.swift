//
//  TabViewController.swift
//  uSurf
//
//  Created by Matthew Jagiela on 10/25/18.
//  Copyright © 2018 Matthew Jagiela. All rights reserved.
//

import UIKit

class TabViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,  UISearchBarDelegate {

    @IBOutlet var navigationBar: UINavigationBar!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    var searchController = UISearchController()
    var iPhoneTabArray = NSMutableArray()
    var iPadTabArray = NSMutableArray()
    let iCloud = iCloudHandler()
    let savedData = SavedDataHandler()
    let theme = ThemeHandler()
    //Optional variables these do not take up memory until they are called by a method execution
    lazy var matchediPhoneTabs = [Int]() //This is going to be where the bookmarks matching with the search is
    lazy var matchediPadTabs = [Int]()
    lazy var isSearching = false
    var browserTag = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //Load The Data:
        iPhoneTabArray = iCloud.getiPhoneTabArray()
        iPadTabArray = iCloud.getiPadTabArray()
        theming()
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        //Add an iCloud handler... This will execute whenever there is an iCloud update...
        NotificationCenter.default.addObserver(self, selector: #selector(iCloudUpdate(notification:)), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: NSUbiquitousKeyValueStore.default)
        
    }
    @objc private func iCloudUpdate(notification:NSNotification){
        iPhoneTabArray = iCloud.getiPhoneTabArray()
        iPadTabArray = iCloud.getiPadTabArray()
        isSearching = false
        tableView.reloadData()
    }
    func theming(){ //Lets handle the theme!
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self as? UISearchResultsUpdating //search results are handled in this class
        searchController.hidesNavigationBarDuringPresentation = false //Make sure the nav bar stays
        searchController.dimsBackgroundDuringPresentation = true //Not sure
        searchController.searchBar.delegate = self // we want to use delegate methods here
        tableView.tableFooterView = UIView(frame:.zero) //Make sure that the entire thing is in frame
        tableView.rowHeight = 71 //Row height for the text
        navigationBar.barTintColor = theme.getBarTintColor() //Set the real color of the bar
        navigationBar.tintColor = theme.getTintColor() //Set text of the bar
        self.view.backgroundColor = theme.getBarTintColor() //Set the background text
        let textAttributes = [NSAttributedString.Key.foregroundColor:theme.getTintColor()] //Set the navigation text color
        navigationBar.titleTextAttributes = textAttributes //Actually update the thing
        tableView.backgroundColor = theme.getBarTintColor() //When there is no cells the view will be this color
        searchBar.barStyle = theme.getSearchStyle() //Set the theme of the search bar
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField //extract the text
        
        textFieldInsideSearchBar?.textColor = theme.getTintColor() //Change the color to white
        
        
        
    }
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return theme.getStatusBarColor()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) { //There is some search happening so we need to start trying to find the timer
        print("BookarkTableViewController: We are searching")
        if let searchedItem = searchBar.text , searchBar.text != ""{
            let searchArray = iPhoneTabArray as! [String]
            matchediPhoneTabs = searchArray.indices.filter{ //This is searching through the iPhone tab array for matches
                searchArray[$0].localizedCaseInsensitiveContains(searchedItem)
            }
            let iPadSearchArray = iPadTabArray as! [String]
            matchediPadTabs = iPadSearchArray.indices.filter{ //This is searching through the iPad tab arrays to find a match
                iPadSearchArray[$0].localizedCaseInsensitiveContains(searchedItem)
            }
            isSearching = true
        }
        else{
            isSearching = false
        }
        tableView.reloadData()
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section == 0){
            return "iPhone"
        }
        else{
            return "iPad"
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(isSearching){
            if(section == 0){
                return matchediPhoneTabs.count
            }
            else{
                return matchediPadTabs.count
            }
        }
        else{
            if(section == 0){
                return iPhoneTabArray.count
            }
            else{
                return iPadTabArray.count
            }
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tabCells")
        if(isSearching){ //We are searching so the table has to represent this
            if(indexPath.section == 0){ //iPhone while searching
                cell?.textLabel?.text = iPhoneTabArray.object(at: matchediPhoneTabs[indexPath.row]) as? String
            }
            else{
                cell?.textLabel?.text = iPadTabArray.object(at: matchediPadTabs[indexPath.row]) as? String
            }
            
            
        }
        else{
            if(indexPath.section == 0){ //iPhone
                cell?.textLabel?.text = iPhoneTabArray.object(at: indexPath.row) as? String
            }
            else{
                cell?.textLabel?.text = iPadTabArray.object(at: indexPath.row) as? String
            }
        }
        cell?.backgroundColor = theme.getBarTintColor()
        cell?.textLabel?.textColor = theme.getTintColor()
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(isSearching){//We are searching so we have to have the selected row the searched item
            if(indexPath.section == 0){
                //iPhone
                savedData.setLastViewedPage(lastPage: iPhoneTabArray.object(at: matchediPhoneTabs[indexPath.row]) as! String)
                switch browserTag {
                case 1: //Left
                    savedData.setLeftWebPage(URL: iPhoneTabArray.object(at: matchediPhoneTabs[indexPath.row]) as! String)
                    self.performSegue(withIdentifier: "goSplit", sender: self)
                case 2:
                    savedData.setRightWebPage(URL: iPhoneTabArray.object(at: matchediPhoneTabs[indexPath.row]) as! String)
                    self.performSegue(withIdentifier: "goSplit", sender: self)
                default:
                    //savedData.setLastViewedPage(lastPage: historyArray[searchedIndex] as! String)
                    self.performSegue(withIdentifier: "goHome", sender: self) //Go home and load the page
                }
                
            }
            else{
                savedData.setLastViewedPage(lastPage: iPadTabArray.object(at: matchediPadTabs[indexPath.row]) as! String)
                switch browserTag {
                case 1: //Left
                    savedData.setLeftWebPage(URL: iPadTabArray.object(at: matchediPadTabs[indexPath.row]) as! String)
                    self.performSegue(withIdentifier: "goSplit", sender: self)
                case 2:
                    savedData.setRightWebPage(URL: iPadTabArray.object(at: matchediPadTabs[indexPath.row]) as! String)
                    self.performSegue(withIdentifier: "goSplit", sender: self)
                default:
                    //savedData.setLastViewedPage(lastPage: historyArray[searchedIndex] as! String)
                    self.performSegue(withIdentifier: "goHome", sender: self) //Go home and load the page
                }
            }
            
        }
        else{
            if(indexPath.section == 0){
                savedData.setLastViewedPage(lastPage: iPhoneTabArray.object(at: indexPath.row) as! String)
                switch browserTag {
                case 1: //Left
                    savedData.setLeftWebPage(URL: iPhoneTabArray.object(at: indexPath.row) as! String)
                    self.performSegue(withIdentifier: "goSplit", sender: self)
                case 2:
                    savedData.setRightWebPage(URL: iPhoneTabArray.object(at: indexPath.row) as! String)
                    self.performSegue(withIdentifier: "goSplit", sender: self)
                default:
                    //savedData.setLastViewedPage(lastPage: historyArray[searchedIndex] as! String)
                    self.performSegue(withIdentifier: "goHome", sender: self) //Go home and load the page
                }
            }
            else{
                savedData.setLastViewedPage(lastPage: iPadTabArray.object(at: indexPath.row) as! String)
                switch browserTag {
                case 1: //Left
                    savedData.setLeftWebPage(URL: iPadTabArray.object(at: indexPath.row) as! String)
                    self.performSegue(withIdentifier: "goSplit", sender: self)
                case 2:
                    savedData.setRightWebPage(URL: iPadTabArray.object(at: indexPath.row) as! String)
                    self.performSegue(withIdentifier: "goSplit", sender: self)
                default:
                    //savedData.setLastViewedPage(lastPage: historyArray[searchedIndex] as! String)
                    self.performSegue(withIdentifier: "goHome", sender: self) //Go home and load the page
                }
            }
        }
        self.performSegue(withIdentifier: "goHome", sender: self)
        
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == .delete){ //We need to figure out how to delete
            if(indexPath.section == 0){ //iPhone
                iPhoneTabArray.removeObject(at: indexPath.row)
                iCloud.setiPhoneTabArray(iPhoneTabArray: iPhoneTabArray)
            }
            else{
                iPadTabArray.removeObject(at: indexPath.row)
                iCloud.setiPadTabArray(iPadTabArray: iPadTabArray)
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
        else{
            
        }
    }
   
    @objc func canRotate() -> Void {}
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}